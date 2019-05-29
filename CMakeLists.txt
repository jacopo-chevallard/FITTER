# CMake project file for fitter
cmake_minimum_required (VERSION 2.6)
project (fitter)
enable_language (Fortran)

# Set library name
set(LIBRARY_NAME fitter)

# Set the CMAKE_MODULE_PATH
LIST (APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
LIST (APPEND CMAKE_MODULE_PATH $ENV{CMAKE_MACROS})
LIST (APPEND CMAKE_MODULE_PATH "$ENV{CMAKE_MACROS}/external")

# Set flag for Shippable CD/CI
if (SHIPPABLE)
  set (SHIPPABLE ON CACHE INTERNAL "Flag for Shippable CD/CI")
  set (SHIPPABLE_SUFFIX "_Shippable" CACHE INTERNAL "Suffix for file versions tailored at working with Shippable CI/CD")
endif (SHIPPABLE)

include(ExternalProject)
include(libFindGeneral)

# Include default flags for Fortran and C compiler
if ( NOT Fortran_FLAGS_ARE_SET )
  if ( CMAKE_Fortran_COMPILER_ID STREQUAL GNU )
    include( GNU_Fortran_Flags )
  elseif ( CMAKE_Fortran_COMPILER_ID STREQUAL Intel )
    include( Intel_Fortran_Flags )
  endif ( CMAKE_Fortran_COMPILER_ID STREQUAL GNU )
endif ( NOT Fortran_FLAGS_ARE_SET )

# Probelms with RPATH
if ( NOT RPATH_CONFIG )
  include ( General_rpath_config ) 
endif ( NOT RPATH_CONFIG )


# Whether you build a static or shared library
set(LIBRARY_TYPE SHARED)
if (CMAKE_LIBRARY_TYPE)
  set(LIBRARY_TYPE ${CMAKE_LIBRARY_TYPE})
endif (CMAKE_LIBRARY_TYPE)

if (${LIBRARY_TYPE} STREQUAL "STATIC")
  set (CMAKE_LIBRARY_PREFIX ${CMAKE_STATIC_LIBRARY_PREFIX} CACHE INTERNAL "Prefix for CMake libraries")
  set (CMAKE_LIBRARY_SUFFIX ${CMAKE_STATIC_LIBRARY_SUFFIX} CACHE INTERNAL "Suffix for CMake libraries")
elseif (${LIBRARY_TYPE} STREQUAL "SHARED")
  set (CMAKE_LIBRARY_PREFIX ${CMAKE_SHARED_LIBRARY_PREFIX} CACHE INTERNAL "Prefix for CMake libraries")
  set (CMAKE_LIBRARY_SUFFIX ${CMAKE_SHARED_LIBRARY_SUFFIX} CACHE INTERNAL "Suffix for CMake libraries")
endif (${LIBRARY_TYPE} STREQUAL "STATIC")

# Library installation directory
set (CMAKE_LIBDIR ${CMAKE_INSTALL_PREFIX}/lib)

# Header files installation directory
set (CMAKE_INCLUDEDIR ${CMAKE_INSTALL_PREFIX}/include/${LIBRARY_NAME})

# Binary files installation directory
set (CMAKE_BINDIR ${CMAKE_INSTALL_PREFIX}/bin)

# Set installation directory for *mod files
set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/mod_files)

# Source files used to build the library
FILE(GLOB SRC_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  src/lib/*.f90 src/lib/*.F90)

# Command to build the library
add_library(
  ${LIBRARY_NAME}
  ${LIBRARY_TYPE} 
  ${SRC_FILES}
)

libfind_detect (PENF 
  FIND_PATH penf.mod INCLUDE_DIRS ${CMAKE_INSTALL_PREFIX}/include/penf
  FIND_LIBRARY penf LIBRARY_DIRS ${CMAKE_INSTALL_PREFIX}/lib NO_DEFAULT_PATH ${CMAKE_NO_DEFAULT_PATH})

if (NOT PENF_FOUND)
  if (NOT TARGET EXT_penf)
    include(external_penf)
    add_dependencies (${LIBRARY_NAME} EXT_penf)
  endif (NOT TARGET EXT_penf)
endif (NOT PENF_FOUND)

target_link_libraries (${LIBRARY_NAME} ${PENF_LIBRARIES})
include_directories(${PENF_INCLUDE_DIR})

# install library
install(
  TARGETS ${LIBRARY_NAME} 
  ARCHIVE DESTINATION ${CMAKE_LIBDIR}
  LIBRARY DESTINATION ${CMAKE_LIBDIR}
)

# install header (*mod) files
install(
  DIRECTORY ${CMAKE_Fortran_MODULE_DIRECTORY}/ 
  DESTINATION ${CMAKE_INCLUDEDIR}
)

# configure a number version file to pass some of the CMake settings
# to the source code
configure_file(
  $ENV{CMAKE_MACROS}/pkg-config.pc.cmake
  ${CMAKE_CURRENT_SOURCE_DIR}/${LIBRARY_NAME}.pc
  @ONLY
)

configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/${LIBRARY_NAME}_meta_info.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/cmake/${LIBRARY_NAME}_meta_info.cmake"
)

add_custom_command(TARGET ${LIBRARY_NAME} PRE_BUILD COMMAND cmake -P ${CMAKE_CURRENT_BINARY_DIR}/cmake/${LIBRARY_NAME}_meta_info.cmake)

# install configuration file
install(
  FILES ${CMAKE_CURRENT_SOURCE_DIR}/${LIBRARY_NAME}.pc ${CMAKE_CURRENT_BINARY_DIR}/cmake/${LIBRARY_NAME}_meta_info.json
  DESTINATION ${CMAKE_LIBDIR}/pkgconfig
  COMPONENT config
  )

set_target_properties(
  ${LIBRARY_NAME}
  PROPERTIES COMPILE_FLAGS "${CMAKE_Fortran_COMPILER_FLAGS} ${Fortran_FLAGS}"
  )

set ( FITTER_INCLUDE_DIR "${CMAKE_INCLUDEDIR}" CACHE INTERNAL "fitter include directory" )
set ( FITTER_LIBRARIES_DIR "${CMAKE_LIBDIR}" CACHE INTERNAL "fitter library directory" )
set ( FITTER_LIBRARIES "${LIBRARY_NAME}" CACHE INTERNAL "fitter library" )

FILE(GLOB TEST_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  src/tests/fitter_test_*.f90)

# Testing routines
if ( COMPILE_TESTS )

  foreach(test ${TEST_FILES})

    get_filename_component( execFile ${test} NAME_WE )

    add_executable(${execFile}
      ${test}
      )

    target_link_libraries(${execFile}  ${LIBRARY_NAME} ${PENF_LIBRARIES})
    include_directories(${PENF_INCLUDE_DIR})

    add_test(${execFile} ${execFile})

  endforeach(test)

endif ( COMPILE_TESTS )

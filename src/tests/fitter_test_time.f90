!< FITTER test.
program fitter_test_time
!-----------------------------------------------------------------------------------------------------------------------------------
!< FITTER test.
!-----------------------------------------------------------------------------------------------------------------------------------
use, intrinsic :: iso_fortran_env, only : real64
use fitter
!-----------------------------------------------------------------------------------------------------------------------------------

!-----------------------------------------------------------------------------------------------------------------------------------
implicit none
type(timer) :: chronos !< The timer.
!-----------------------------------------------------------------------------------------------------------------------------------

!-----------------------------------------------------------------------------------------------------------------------------------
call chronos%tic(name='foo')
call foo
call chronos%toc

call chronos%tic(name='bar')
call bar
call chronos%toc

call chronos%tic
call bar
call chronos%toc

print '(A,F8.5,A)', 'Time spent in "foo": ', chronos%time(name='foo'), ' [s]'
print '(A,F8.5,A)', 'Whole time spent: ', chronos%time(), ' [s]'
!-----------------------------------------------------------------------------------------------------------------------------------
contains
  subroutine foo
  !---------------------------------------------------------------------------------------------------------------------------------
  !< Waste some times.
  !---------------------------------------------------------------------------------------------------------------------------------
  integer :: i !< Counter.
  real    :: r !< Dummy real.
  !---------------------------------------------------------------------------------------------------------------------------------

  !---------------------------------------------------------------------------------------------------------------------------------
  do i=1, 100000
    r = i**0.3
  enddo
  !---------------------------------------------------------------------------------------------------------------------------------
  endsubroutine foo

  subroutine bar
  !---------------------------------------------------------------------------------------------------------------------------------
  !< Waste some more times.
  !---------------------------------------------------------------------------------------------------------------------------------
  integer :: i !< Counter.
  real    :: r !< Dummy real.
  !---------------------------------------------------------------------------------------------------------------------------------

  !---------------------------------------------------------------------------------------------------------------------------------
  do i=1, 150000
    r = i**0.3
  enddo
  !---------------------------------------------------------------------------------------------------------------------------------
  endsubroutine bar
endprogram fitter_test_time

!< FITTER test.
program fitter_test_times
!-----------------------------------------------------------------------------------------------------------------------------------
!< FITTER test.
!-----------------------------------------------------------------------------------------------------------------------------------
use, intrinsic :: iso_fortran_env, only : real64
use fitter
!-----------------------------------------------------------------------------------------------------------------------------------

!-----------------------------------------------------------------------------------------------------------------------------------
implicit none
type(timer)               :: chronos  ! The timer.
real(real64), allocatable :: times(:) ! Times tracked.
!-----------------------------------------------------------------------------------------------------------------------------------

!-----------------------------------------------------------------------------------------------------------------------------------
call chronos%start(name='foo')
call foo
call chronos%stop

call chronos%start(name='bar')
call bar
call chronos%stop

call chronos%start
call bar
call chronos%stop

times = chronos%times()

call chronos%clean

print*, times
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
endprogram fitter_test_times
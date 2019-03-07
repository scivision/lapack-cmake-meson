
use, intrinsic :: iso_fortran_env, only: stderr=>error_unit, sp=>real32
implicit none

integer, parameter :: LRATIO=8
integer, parameter :: M = 5, L = 3

integer :: Lwork, svdinfo

real(sp) :: R(M,M), U(M,M),VT(M,M), S1(M-1,L), S2(M-1,L)
real(sp) :: S(M,M),RWORK(LRATIO*M),ang(L),SWORK(LRATIO*M) !this Swork is real

LWORK = LRATIO*M !at least 5M for sgesvd

call sgesvd('A','N',M,M,R,M,S,U,M,VT,M, SWORK, LWORK,svdinfo)

if (svdinfo /= 0) then
  write(stderr,*) 'SGESVD return code',svdinfo,'  LWORK:',LWORK,'  M:',M
  if (M /= LWORK/LRATIO) error stop 'possible LWORK overflow'
endif

print *,'OK: Fortran SVD'

end program

module demo_svd
use, intrinsic :: iso_fortran_env, only: stderr=>error_unit, sp=>real32
implicit none

integer, parameter :: LRATIO=8
integer, parameter :: M=3, N=3

integer, parameter :: Lwork = LRATIO*M !at least 5M for sgesvd

real(sp) :: U(M,M), VT(N,N)
real(sp) :: S(N), SWORK(LRATIO*M) !this Swork is real

interface
  module integer function svd(A, B) result(info)
    real(sp), intent(in) :: A(M, N), B(M, 1)
  end function svd
end interface

contains

subroutine errchk(info)

integer, intent(in) :: info

if (info /= 0) then
  write(stderr,*) 'SGESVD return code', info
  if (info > 0) write(stderr,'(A,I3,A)') 'index #',info,' has sigma=0'
  stop 1
endif

end subroutine errchk

end module demo_svd


program demo
! FIXME not for PGI 18.10
! use, intrinsic :: iso_fortran_env, only: compiler_version
use demo_svd
implicit none

integer :: info
real(sp) :: A(M, N), B(M,1)

! print *,compiler_version()

A = reshape([3.,       1., 1., &
             sqrt(2.), 2., 0., &
             0.,       1., 1.], shape(A), order=[2,1])

B = reshape([8., 4.+sqrt(2.), 5.], shape(B), order=[2,1])


info = svd(A, B)

call errchk(info)

print *,'OK: Fortran SVD'

end program

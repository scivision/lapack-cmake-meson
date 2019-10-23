submodule (demo_svd) atlas

contains

module procedure svd
!! For lapack95 and atlas, the sgesv API is:
!!  sgesv( N, nrhs, a, lda, ipiv, b, ldb, info )
integer :: ipiv(N)
real :: truthX(M), errmag(M)

call sgesv(M, size(B,2), A, M, ipiv, B, M, info)

truthX = [1., 2., 3.]

errmag = abs(B(:,1)-truthX)
if (any(errmag > 1e-3)) then
  print *,'estimated solution: ',B
  print *,'true input: ',truthX
  write(stderr,*) 'large error on singular values', errmag
  error stop
endif

end procedure svd

end submodule atlas

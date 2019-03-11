submodule (demo_svd) atlas

contains

module procedure example

integer :: i

call sgemm('N','T',M,M,N,1._sp, A, M, A, M, 0._sp, U, M)

! U = matmul(A, transpose(A))

do i = 1,size(U,1)
  print "(/,10F7.3)", U(i,:)
enddo

end procedure example

end submodule atlas

submodule (demo_svd) lapack

contains

module procedure svd
real(sp) :: truthS(N), errmag(N)

truthS = [3.97303, 1.46913, 1.02795]

call sgesvd('A','N',M,N, A, M,S,U,M,VT, N, SWORK, LWORK, info)

errmag = abs(s-truthS)
if (any(errmag > 1e-3)) then
  print *,'estimated singular values: ',S
  print *,'true singular values: ',truthS
  write(stderr,*) 'large error on singular values', errmag
  error stop
endif

end procedure svd

end submodule lapack

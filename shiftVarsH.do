/// Mata function to shift horizontally variables according to an "m" variable

cap mata mata drop shiftVarsH()
mata:
	function shiftVarsH(x,m){
		st_view(X=.,.,x)
		st_view(M=.,.,m)
		R = X
		for (i=1; i<=rows(X); i++){
			for(j=1; j<=cols(X); j++){
				if (j-M[i]>=0){
					X[i,j] = R[i,j-M[i]+1]
				}
				else{
					X[i,j] = .
				}
			}
		}
	}
end

/* /// EXAMPLE OF USAGE
clear all
set obs 100
forv i = 1/100{
	g foo`i' = 1
}
g stepdiff = _n
mata: shiftVarsH("foo1-foo100","stepdiff")
*/

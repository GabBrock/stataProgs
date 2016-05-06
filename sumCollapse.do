/// collapse in order to obtain the sum of the variables specified. Byable command. 
/// Optionally keeps the last non-missing observation of the variables specified in "keep"

cap program drop sumCollapse
program define sumCollapse 
	syntax varlist(min=1 numeric) [, by(varname) keep(varlist min=1)]
	if !mi("`by'"){ 
		sort `by'
		loc bycolumn "by `by':"
	}
	keep `varlist' `by' `keep'
	foreach var of varlist `varlist'{
		qui `bycolumn' replace `var' = sum(`var')
	}
	foreach var of varlist `keep'{
		qui `bycolumn' replace `var' = `var'[_n-1] if mi(`var')
	}
	qui `bycolumn' keep if _n == _N
end

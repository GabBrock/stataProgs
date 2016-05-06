/// program aimed at converting string date variables to stata format date variables. 
/// It is basically just a wrapper of "date" command plus the possibility to automatically rename and format new numerical vars.
/// syntax: variable names to be converted. Optionally: replace or gen(list of new names) + the format of the date (as in the "date" command);
/// one can even specify "Quarter", "Month" and/or "Week" in order to have the quarterly, monthly or weekly variable

cap program drop dateConvert
program dateConvert
	syntax varlist(min=1) [if] [in], [REPlace GENerate(namelist min=1) FORmat(name min=1) Month Week Quarter]
		if !mi("`replace'") & !mi("`generate'"){
			di as error "Specify either REPlace or GENerate(stub). If none is specified, generate(_varname) is assumed"
			exit
		}
		loc numvars: list sizeof local(varlist)
		loc numnames: list sizeof local(generate)
		if !mi("`generate'") & `numvars' != `numnames'{
			di as error "New variable names number is different from number of variables"
			exit
		}
		if regexm("`format'","[0-9][0-9]"){
			loc digits = regexs(0) 
		}
		if !mi("`format'") & (!inlist("`format'","MD`digits'Y","M`digits'YD","DM`digits'Y","D`digits'YM","`digits'YMD","`digits'YDM")){
			di as error "Date format has to be any permutation of M,D and [##]Y, where ##, if specified, indicates the default century for two-digit years. Default is DMY"
			exit
		}
		if mi("`format'"){
			di "No date format passed on to the program. Date-Month-Year (DMY) assumed"
			loc format "DMY"
		}
		foreach var of varlist `varlist'{
			if !mi("`replace'") | (mi("`replace'") & mi("`generate'")){
				loc generate _`var'
			}
			gettoken newname generate : generate
			g int `newname' = date(`var',"`format'") `if' `in'
			if !mi("`month'"){
				g m`newname' = mofd(`newname') `if' `in'
				format %tm m`newname'
			}
			if !mi("`week'"){
				g w`newname' = wofd(`newname') `if' `in'
				format %tw w`newname'
			}
			if !mi("`quarter'"){
				g q`newname' = qofd(`newname') `if' `in'
				format %tq q`newname'
			}
			format %td `newname'
			if !mi("`replace'"){
				drop `var'
				ren `newname' `var'
			}
		}
end
		


************ PUT ALL THE INDIVIDUAL DATABASES (CHEATING) TOGETHER

foreach archivo in 2006 2007 2008{ 
	use "$cd_data/Bases Madre/Secundario`archivo'.dta", clear
	capture drop grado
	gen grado = 3
	ren grado GradoSecundaria
	destring GradoSecundaria, replace
	ren prop_3 prop
	drop if prop ==.
	capture drop ClaveUnicaEscuelaTurno
	tostring turno, replace
	gen ClaveUnicaEscuelaTurno =clavedelaescuela + "_" + turno
	capture drop year
	gen year = `archivo'
	save "$cd_data/Bases Madre/Secundario`archivo'_Expanded.dta", replace
}

foreach archivo in 2009 2010 2011 2012 2013{ 
	use "$cd_data/Bases Madre/Secundario`archivo'.dta", clear
	replace turno = "1" if turno == "MATUTINO"
	replace turno = "2" if turno == "VESPERTINO"
	replace turno = "3" if turno == "NOCTURNO"
	replace turno = "4" if turno == "DISCONTINU"
	capture drop ClaveUnicaEscuelaTurno
	gen clave_mun = ent + clavemun

	gen clave_loc = ent + clavemun +clavemun

	gen ClaveUnicaEscuelaTurno =clavedelaescuela + "_" + turno

	expand 3
	bysort ClaveUnicaEscuelaTurno: gen GradoSecundaria = _n 
	gen prop = prop_1 if GradoSecundaria ==1
	replace prop = prop_2 if GradoSecundaria ==2
	replace prop = prop_3 if GradoSecundaria ==3
	drop if prop==.
	cap drop year
	gen year = `archivo' 
	save "$cd_data/Bases Madre/Secundario`archivo'_Expanded.dta", replace
}


use "$cd_data/Bases Madre/Secundario2006_Expanded.dta", clear

foreach archivo in 2007 2008 2009 2010 2011 2012 2013{ 
	append using "$cd_data/Bases Madre/Secundario`archivo'_Expanded.dta", force
}

keep if year !=.
capture drop clave_mun

gen clave_mun = ent + clavemun
replace prop = . if prop <0
save "$cd_data/BasesAnalisis/Secundario2006-2013ParaAnalisis.dta", replace

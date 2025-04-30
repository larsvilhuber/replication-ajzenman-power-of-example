

*** Process Census data

import delimited using  "$cd_data/Bases Madre/Census/population2005.csv", clear

tostring cve_inegi, gen(clave_mun)
replace clave_mun = "0" + clave_mun if cve_inegi<10000
keep clave_mun total
ren total total_2005
drop if clave_mun == "."
save "$cd_data/Censo/Population_2005.dta", replace


import delimited using  "$cd_data/Bases Madre/Census/population2010.csv", clear

tostring cve_inegi, gen(clave_mun)
replace clave_mun = "0" + clave_mun if cve_inegi<10000
keep clave_mun total
ren total total_2010
drop if clave_mun == "."
save "$cd_data/Censo/Population_2010.dta", replace


import delimited using  "$cd_data/Bases Madre/Census/population2015.csv", clear

tostring cve_inegi, gen(clave_mun)
replace clave_mun = "0" + clave_mun if cve_inegi<10000
keep clave_mun total
ren total total_2015
drop if clave_mun == "."
save "$cd_data/Censo/Population_2015.dta", replace

drop if clave_mun =="."
merge 1:1 clave_mun using "$cd_data/Censo/Population_2010.dta"

drop _merge

merge 1:1 clave_mun using "$cd_data/Censo/Population_2005.dta"

drop _merge





egen pob_tot_int = rowmean(total_2005 total_2010 total_2015)
format pob_tot_int %10.0g

keep clave_mun pob_tot_int
merge  1:1 clave_mun using "$cd_data/Bases Madre/clave_mun.dta"
keep if _merge ==3
drop _merge
save "$cd_data/Censo/Population_MUN.dta", replace





import delimited using  "$cd_data/Bases Madre/Census/Census_raw.csv", clear
ren entidad ent
tostring ent, gen(ENT)
tostring mun, gen(MUN)
tostring loc, gen(LOC)

replace ENT = "0" + ENT if ent <10
replace MUN = "00" + MUN if mun <10
replace MUN = "0" + MUN if mun >=10 & mun<100
replace LOC = "000" + LOC if loc <10
replace LOC = "00" + LOC if loc >=10 & loc<100
replace LOC = "0" + LOC if loc >=100 & loc<1000

gen clave_mun = ENT+MUN
gen clave_loc = ENT+MUN+LOC
*drop if inlist(nom_loc, "Total nacional", "Localidades de una vivienda", "Localidades de dos viviendas", "Total de la Entidad", "Localidades de una vivienda", "Localidades de dos viviendas")

replace vph_radio = "." if vph_radio == "N/D"
replace vph_radio = "." if vph_radio == "*"

destring vph_radio, replace

gen tasa_radio_missing = vph_radio/vivtot
gen tasa_radio = tasa_radio_missing
replace tasa_radio_missing = . if tasa_radio_missing<0
bys clave_mun: egen prom_radio = mean(tasa_radio_missing)
replace tasa_radio = prom_radio if tasa_radio_missing ==.

save "$cd_data/Censo/Radio_Localidad.dta", replace

*** Process taxes data

foreach archivo in 2006 2007 2008 2009 2010 2011 2012 2013 { 
	import delimited using  "$cd_data/Bases Madre/Tax/tax_`archivo'.csv", clear
	ren v1 clave_mun
	ren v2 estado
	ren v3 municipio
	ren v4 total
	drop if total == "TOTAL"
	replace total = subinstr(total, ",", "",.) 
	destring total, replace
	gen year = 	`archivo'
	save "$cd_data/Censo/Tax_`archivo'.dta", replace
}


use "$cd_data/Censo/Tax_2006.dta", replace
foreach archivo in 2007 2008 2009 2010 2011 2012 2013 { 
	append using "$cd_data/Censo/Tax_`archivo'.dta", force
	
}

drop if clave_mun ==""
replace total =0 if total ==.
gen mis_tot=total==0

save "$cd_data/Censo/Taxes_mun_2006_2013.dta", replace

/*
use "$cd_data/Censo/Population_MUN.dta", replace
keep clave_mun
expand 8
bys clave_mun: gen year = 2005+_n

merge 1:1 clave_mun year  using  "$cd_data/Censo/Taxes_mun_2006_2013.dta", gen (merg)
replace total = 0 if total ==.
replace mis_tot = total ==0
drop merg

save "$cd_data/Censo/Taxes_mun_2006_2013.dta", replace

*/
*** Process crime data

foreach archivo in 06 07 08 09 10 { 
	import dbase "$cd_data/Bases Madre/Homicides/DEFUN`archivo'.dbf", clear
	keep if PRESUNTO ==2
	tostring ENT_REGIS, gen (ent)
	replace ent = "0" + ent if ENT_REGIS<10
	tostring MUN_REGIS, gen (mun)
	replace mun = "00" + mun if MUN_REGIS<10
	replace mun = "0" + mun if MUN_REGIS>=10 & MUN_REGIS<100
	gen clave_mun = ent+mun
	gen homicidios = 1
	collapse (sum) homicidios, by (clave_mun)
	gen year = 2000+`archivo'
	save "$cd_data/Censo/Homicides_`archivo'.dta", replace

}


foreach archivo in 11 12 13 { 
	import dbase "$cd_data/Bases Madre/Homicides/DEFUN`archivo'.dbf", clear
	keep if PRESUNTO ==2
	ren ENT_REGIS ent
	ren MUN_REGIS mun
	gen clave_mun = ent+mun
	gen homicidios = 1
	collapse (sum) homicidios, by (clave_mun)
	gen year = 2000+`archivo'
	save "$cd_data/Censo/Homicides_`archivo'.dta", replace
}

use "$cd_data/Censo/Homicides_06.dta", replace
foreach archivo in 07 08 09 10 11 12 13 { 
	append using "$cd_data/Censo/Homicides_`archivo'.dta", force
	
}



save "$cd_data/Censo/Homicides_2006_2013_Poblacion.dta", replace

use "$cd_data/Bases Madre/clave_mun.dta", clear
expand 8
bys clave_mun: gen year = _n+2005

merge 1:1 clave_mun year using "$cd_data/Censo/Homicides_2006_2013_Poblacion.dta"
replace homicidios = 0 if homicidios ==.
drop _merge

merge m:1 clave_mun using "$cd_data/Censo/Population_MUN.dta"
drop _merge

gen HOMI_CAP_MUN = homicidios/pob_tot_int
replace HOMI_CAP_MUN = 0 if HOMI_CAP_MUN ==.
save "$cd_data/Censo/Homicides_2006_2013_Poblacion.dta", replace


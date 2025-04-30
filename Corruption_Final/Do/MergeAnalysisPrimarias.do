

*cd "C:/Users/Nicolas_2/Dropbox/Cheating in Mexico/"
*cd "/Users/Nico/Dropbox/Cheating in Mexico/"


************ PUT ALL THE INDIVIDUAL DATABASES (CHEATING) TOGETHER 


foreach archivo in 2006 2007 2008 2009 2010 2011 2012 2013{ 
	use "$cd_data/Bases Madre/Primario`archivo'.dta", clear
	capture drop ClaveUnicaEscuelaTurno
	capture ren entidad ent
	tostring turno, replace
	gen enti_num = ent
	tostring ent, replace
	
	if `archivo'== 2008 | `archivo'== 2013 {
		replace ent= "0"+ent if enti_num<10
	}
	capture drop year
	gen clave_mun = ent + clavemun
	
	replace turno = "1" if turno == "MATUTINO"
	replace turno = "2" if turno == "VESPERTINO"
	replace turno = "3" if turno == "NOCTURNO"
	replace turno = "4" if turno == "DISCONTINU"

	gen ClaveUnicaEscuelaTurno =clavedelaescuela + "_" + turno + "_" +clave_mun

	expand 4
	bysort ClaveUnicaEscuelaTurno: gen GradoPrimaria = _n 
	gen prop = prop_3 if GradoPrimaria ==1
	replace prop = prop_4 if GradoPrimaria ==2
	replace prop = prop_5 if GradoPrimaria ==3
	replace prop = prop_6 if GradoPrimaria ==4

	drop if prop==.
	gen year = `archivo'
	save "$cd_data/Bases Madre/Primario`archivo'_Expanded.dta", replace
}

use "$cd_data/Bases Madre/Primario2006_Expanded.dta", clear

foreach archivo in 2007 2008 2009 2010 2011 2012 2013{ 
	append using "$cd_data/Bases Madre/Primario`archivo'_Expanded.dta", force
}

keep if year !=.

capture drop clave_mun
gen clave_mun = ent + clavemun
replace prop = . if prop <0
save "$cd_data/BasesAnalisis/Primario2006-2013ParaAnalisis.dta", replace


*** merge with corruption data

* TEST(1)
use "$cd_data/BasesAnalisis/Primario2006-2013ParaAnalisis.dta", clear
** first, keep only relevant municipalities for the period of analysis
merge m:1 clave_mun using "$cd_data/BasesAnalisis/ListadoMunicipiosCompleto.dta", gen(m)
keep if m == 3
drop m



*** second, merge with corruption data

merge m:1 year clave_mun using "$cd_data/Data_Corruption/TodosLosMuni_ConAudits_ConAlreadyAudited.dta", gen(mm)

keep if mm==3

tostring year, gen(year_string)

tostring GradoPrimaria, gen(grade_string)
gen SchoolGrade = ClaveUnicaEscuelaTurno + "_"+ grade_string

** define corruption

cap drop Corrupt

gen Corrupt = 0
replace Corrupt = 1 if unauthorized > 0 


replace prop_3 = . if prop_3 <0
replace prop_4 = . if prop_4 <0
replace prop_5 = . if prop_5 <0
replace prop_6 = . if prop_6 <0

replace prop_tot = . if prop_tot <0

save "$cd_data/BasesAnalisis/FinalDataBase_Primaria.dta", replace

* grande fe, year fe
qui ta grade_string, gen(grade_)
qui ta year, gen (yy)

*cap ren NRO nro
*bysort clave_mun: egen maximo = max(nro)


*** Diferentes definiciones de corrupcion:
su unauthorized if unauthorized >0, de

* shift FE
ta turno, gen(Turn_)



*************** political data: year corruption happened

merge m:m clave_mun year using "$cd_data/Base Presidentes/Muni_Presidentes_Desfasado.dta", gen(tt)
keep if tt ==3


*************** political data: year corruption was revealed
merge m:m clave_mun year using "$cd_data/Base Presidentes/Muni_Presidentes.dta", gen(mmm) force

keep if mmm==3

*************** crime data

merge m:1 clave_mun year using "$cd_data/Censo/Homicides_2006_2013_Poblacion.dta", gen(merg)
keep if merg ==3
drop merg

keep if inlist(year,2006,2007,2008,2009,2010,2011,2012,2013)

*************** taxes data

merge m:1 clave_mun year using "$cd_data/Censo/Taxes_mun_2006_2013.dta", gen(m_income)
keep if m_income ==3
drop m_income

*************** political data collapsed at the 3-main-parties-level (need this to crate the dummy: same party local and national level)

merge m:1 year clave_mun using  "$cd_data/Base Presidentes/Partidos_Alianzas.dta", gen(merge_PD)
keep if year<2014 & year >2005
keep if merge_PD !=2
ren winner winner_D

merge m:1 year clave_mun using  "$cd_data/Base Presidentes/Partidos_Alianzas_Hecho.dta", gen(merge_P)
keep if year<2014 & year >2005
keep if merge_P !=2


gen PartG = "PAN"
replace PartG= "PRI" if year>2012
gen MismoPartidoG = 0
replace MismoPartidoG = 1 if PartG == winner_D
replace MismoPartidoG = 1 if PartG == winner_D


drop if prop ==.
gen year_trend = year-2005
qui ta clave_mun, gen(muni_)
** create mun trends
egen Group_Mun= group(clave_mun)
egen Num_Mun = max(Group_Mun)
su Num_Mun
return list
forvalues x = 1/`r(mean)'{
	gen trend_`x' = muni_`x'*year_trend 
}


*year FE, party FE
ta year, gen(yy_)
ta PartidoD, gen(P_)
ta Partido, gen(P_L_)
replace prop = prop*100
cap log close
log using "Tables/Table3.txt", text replace

** TABLE III
areg prop Corrupt Turn_* yy_*  Auditada,  absorb(clavedelae) cluster(clave_mun)
areg prop Corrupt Turn_* yy_*  Auditada P_*,  absorb(clavedelae) cluster(clave_mun)
areg prop Corrupt Turn_* yy_* HOMI_CAP_MUN  total mis_tot CorruptPast Already Auditada P_* MismoPartidoG,  absorb(clavedelae) cluster(clave_mun)
areg prop Corrupt grade_1 grade_2 grade_3 Turn_* yy_* HOMI_CAP_MUN  total mis_tot CorruptPast Already Auditada P_* MismoPartidoG,  absorb(clavedelae) cluster(clave_mun)
areg prop Corrupt grade_1 grade_2 grade_3 Turn_* yy_* HOMI_CAP_MUN  total mis_tot P_* CorruptPast Already Auditada trend* MismoPartidoG,  absorb(clavedelae) cluster(clave_mun)


cap log close


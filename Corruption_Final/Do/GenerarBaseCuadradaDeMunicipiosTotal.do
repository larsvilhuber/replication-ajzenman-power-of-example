



** create balanced panel of corruption by mun-year. 

* keep the municipality codes (clave_mun) from cheating data, 2006-2013 
use "$cd_data/BasesAnalisis/Secundario2006-2013ParaAnalisis.dta", clear
keep clave_mun
duplicates drop
** Expand (to cover all years) and create an empty balanced panel clave_mun-year
expand 15

gen year = .


bysort clave_mun: replace year = 2004 if _n==1
bysort clave_mun: replace year = year[_n-1]+1 if year !=2004


** merge with corruption data
merge m:1 clave_mun year using "$cd_data/Data_Corruption/TotalAuditoriasConMunicipio.dta"
keep if _merge !=2

gen Au2 = Aud
replace Au2 = . if year ==2004

sort clave_mun Au2 year 
cap drop nro_auditoria

bysort clave_mun  Au2 : gen nro_auditoria = _n if Au2==1

** put a 0 in audit where there's a missing

replace Auditada = 0 if Auditada ==.
replace nro = 0 if nro ==.
replace una = 0 if una ==.
drop _merge
gen AlreadyAudited = 0
sort clave_mun year

** Dummy indicating if the mun was already audited (within the sample period)

bysort clave_mun: replace Already = max(Auditada, Already[_n-1]) if year>2005

* Corruption (binary)
gen Corrupt =0
replace Corrupt = 1 if una >0


bysort clave_mun: gen lag_Already  = Already[_n+1]

** Create leads and lags of everything (corruption and audit)

bysort clave_mun: gen lag_Auditada1  = Auditada[_n+1]
bysort clave_mun: gen lag_Auditada2  = Auditada[_n+2]

bysort clave_mun: gen lead_Auditada1  = Auditada[_n-1]
bysort clave_mun: gen lead_Auditada2  = Auditada[_n-2]


bysort clave_mun: gen C_1 = Corrupt[_n+1]
bysort clave_mun: gen C_2 = Corrupt[_n+2]


bysort clave_mun: gen C_menos1 = Corrupt[_n-1]
bysort clave_mun: gen C_menos2 = Corrupt[_n-2]


bysort clave_mun: gen una_1 = unau[_n+1]
bysort clave_mun: gen una_2 = unau[_n+2]

bysort clave_mun: gen una_menos1 = unau[_n-1]
bysort clave_mun: gen una_menos2 = unau[_n-2]

*replace una_menos1 =0 if year==2006 
*replace una_menos2 =0 if inlist(year,2007)

*replace C_menos1 =0 if year==2006 
*replace C_menos2 =0 if inlist(year,2005,2007)


** only a few municipalities presented information about unauthorized use of FISM in 2005, I'm including them here:
*replace C_menos1 = 1 if year ==2006 & inlist(clave_mun, "02002", "02004", "02001", "14039","14067","14098","14101","14120","16050")
*replace C_menos2 = 1 if year ==2007 & inlist(clave_mun, "02002", "02004", "02001", "14039","14067","14098","14101","14120","16050")


*replace una_menos1 = 50 if year ==2006 & inlist(clave_mun, "02002", "02004", "02001", "14039","14067","14098","14101","14120","16050")
*replace una_menos2 = 50 if year ==2007 & inlist(clave_mun, "02002", "02004", "02001", "14039","14067","14098","14101","14120","16050")


** Create percentiles of corruption (25 and 15)
egen p25 = pctile(unauthorized) if inrange(year,2006,2013) & unau>0, p(25)
egen p15 = pctile(unauthorized) if inrange(year,2006,2013) & unau>0, p(15)
** Percentile 25
gen Corrupt_25 = 0
replace Corrupt_25 = 1 if unauthorized >=p25
gen Corrupt_25_1 = 0
replace Corrupt_25_1 = 1 if una_1 >=p25
gen Corrupt_25_2 = 0
replace Corrupt_25_2 = 1 if una_2 >=p25


gen Corrupt_25_menos1 = 0
replace Corrupt_25_menos1 = 1 if una_menos1 >=p25
gen Corrupt_25_menos2 = 0
replace Corrupt_25_menos2 = 1 if una_menos2 >=p25


* Percentil 15
gen Corrupt_15 = 0
replace Corrupt_15 = 1 if unauthorized >=p15
gen Corrupt_15_1 = 0
replace Corrupt_15_1 = 1 if una_1 >=p15
gen Corrupt_15_2 = 0
replace Corrupt_15_2 = 1 if una_2 >=p15


gen Corrupt_15_menos1 = 0
replace Corrupt_15_menos1= 1 if una_menos1 >=p15
gen Corrupt_15_menos2 = 0
replace Corrupt_15_menos2 = 1 if una_menos2 >=p15




keep if inlist(year, 2005, 2006,2007,2008,2009,2010,2011,2012,2013,2014,2015)

** I am not using this. It's an  indicator of the number of audits.

gen VecesAuditada = nro_auditoria

bysort clave_mun: replace Veces = Veces[_n-1] if Auditada ==0
replace Veces = 0 if Veces ==.
bysort clave_mun: gen Seleccionada= Auditada[_n+1]

bysort clave_mun (year) : gen Corr_Acum = sum(Corrupt)
bysort clave_mun (year) : gen Corr_Acum_15 = sum(Corrupt_15)
bysort clave_mun (year) : gen Corr_Acum_25 = sum(Corrupt_25)

gen CorruptPast=0
gen CorruptPast_15=0
gen CorruptPast_25=0

** Dummy: the mun was declared corrupt in the past (within the sample period)
replace CorruptPast = 1 if (Corr_Acum==1 & Corrupt !=1) | Corr_Acum>1
replace CorruptPast_15 = 1 if (Corr_Acum_15==1 & Corrupt_15 !=1) | Corr_Acum_15>1
replace CorruptPast_25 = 1 if (Corr_Acum_25==1 & Corrupt_25 !=1) | Corr_Acum_25>1


bysort clave_mun: gen lag_CorruptPast  = CorruptPast[_n+1]
bysort clave_mun: gen lag_CorruptPast_15  = CorruptPast_15[_n+1]
bysort clave_mun: gen lag_CorruptPast_25  = CorruptPast_25[_n+1]

save "$cd_data/Data_Corruption/TodosLosMuni_ConAudits_ConAlreadyAudited.dta", replace



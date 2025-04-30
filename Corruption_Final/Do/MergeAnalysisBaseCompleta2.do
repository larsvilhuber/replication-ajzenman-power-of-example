
*** Now merge both datasets

*cd "C:\EESP\Corruption_G"

** Open municipality corruption data

use "$cd_data/Data_Corruption/TotalAuditoriasConMunicipio.dta", clear
keep clave_mun
duplicates drop
save "$cd_data/BasesAnalisis/ListadoMunicipiosCompleto.dta", replace


**** only 2006-2013
use "$cd_data/Data_Corruption/TotalAuditoriasConMunicipio.dta", clear




keep if inlist(year,2004,2005, 2006,2007,2008,2009,2010,2011,2012,2013,2014,2015)

* graph density of unauthorized exp

*** FIGURE A2
kdensity unau, title ("") yline(0, lstyle(foreground)) xtitle("") ytitle("")  graphregion(color(white)) ylab(,nogrid) bw(5)
graph save Graph "Graficos/Kernel_Corruption.gph", replace
graph export "Graficos/Kernel_Corruption.pdf", replace

keep clave_mun
duplicates drop
save "$cd_data/BasesAnalisis/ListadoMunicipiosCompleto.dta", replace

** open cheating data

use "$cd_data/BasesAnalisis/Secundario2006-2013ParaAnalisis.dta", clear
destring turno, replace
cap drop numobs
** this is just to get the number of students per grade-year-school

merge 1:1 clavedelaescuela turno GradoS year using "$cd_data/Bases Madre/numobs.dta", gen(asdg)
keep if asdg !=2
drop asdg
** merge with the list (clave_mun) of municipalities that were audited in the relevant period

merge m:1 clave_mun using "$cd_data/BasesAnalisis/ListadoMunicipiosCompleto.dta", gen(m)

* Keep only the municipalities with at least one audit in 2006-2015
keep if m == 3
drop m



*** merge with corruption data

merge m:1 year clave_mun using "$cd_data/Data_Corruption/TodosLosMuni_ConAudits_ConAlreadyAudited.dta", gen(mm)

drop if mm ==2
gen YearTreatment = 0
replace nro_auditoria = 0 if nro_auditoria == .
replace YearTreatment =1 if Auditada ==1 

tostring year, gen(year_string)


* FE: school * grade (1st, 2nd, etc)
tostring GradoSecundaria, gen(grade_string)
drop if !inlist(grade_string, "1","2","3")
cap drop Corrupt
gen Corrupt = 0 
* define corruption as a binary var
replace Corrupt = 1 if unauthorized > 0 & YearTreatment == 1


label var clavedelaescuela "Unique Key per School"
label var turno "morning/evening/night"
label var prop "Proportion of Students Cheating"
label var GradoS "First, Second or Third Year of Secondary School"
label var ClaveUnicaEscuela "Unique Key per School+Turno (evening, morning, night)"
label var tipodees "general, particular, technical, etc"
label var unauthorized "% of unauthorized expenditure"
label var YearTreatment "1 if the mun was treated, 0 otherwise"

label var Corrupt "1 if unauthorized>0, 0 otherwise"

save "$cd_data/BasesAnalisis/FinalDataBase_SecundariaBaseCompleta.dta", replace

* define municipality and locality keys
destring ent, gen(entnum)
tostring entnum, gen(ent_string)
ren claveloc loc
gen claveloc = ent_s + clavemun + loc

ta grade_string, gen(grade_)
ta year, gen (yy)

cap ren NRO nro

bysort clave_mun: egen maximo = max(nro)


** log of corrruption (continuous). Do it for current and 2 leads, 2 lags.
gen ln_unau=ln(unau+1)
gen ln_una_1=ln(una_1+1)
gen ln_una_2=ln(una_2+1)
gen ln_unamenos1=ln(una_menos1+1)
gen ln_unamenos2=ln(una_menos2+1)

** center the variable
qui sum ln_unau, meanonly
gen ln_unau_center=ln_unau-`r(mean)'



ta turno, gen(Turn_)



*************** CLASS SIZE DATA

merge m:1 GradoS clavedelaescuela turno using "$cd_data/Censo/divisiones_escuela.dta", gen(asdasd)
drop if asdasd==2
gen N=numobs/divisiones
** log of size
gen ln_big = ln(N+1)
qui sum ln_big, meanonly
return list
** center log of size, create interactions with corruption AND with the audit var
gen ln_big_center=ln_big-`r(mean)'
gen i_b=ln_big_center*Corrupt
gen i_a=ln_big_center*Auditada



*************** PARTY IN GOVERNMENT (MUN) DATA AND ELECTION (MUN) DATA

*merge with politicians database (year corruption happened)
merge m:m clave_mun year using "$cd_data/Base Presidentes/Muni_Presidentes_Desfasado.dta", gen(tt)
keep if tt ==3

*merge with politicians database (year corruption was released)

merge m:m clave_mun year using "$cd_data/Base Presidentes/Muni_Presidentes.dta", gen(mmm) force

keep if mmm==3


** merge with the dataset that contians the dummy indicating if there were municipal elections that year

merge m:1 clave_mun year using "$cd_data/Base Presidentes/mun_elec.dta", gen(xxxx)
keep if xxxx==3
drop xxxx

** LABOR DATA
merge m:1 clave_mun year using "$cd_data/Censo/Registrados_2006_2013.dta", gen(XX2)
keep if XX2==3
drop XX2

** CRIME DATA

merge m:1 clave_mun year using "$cd_data/Censo/Homicides_2006_2013_Poblacion.dta", gen(merg)
keep if merg ==3
drop merg




keep if inlist(year, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013)

replace Partido = "NS" if Partido == ""
replace PartidoDesf = "NS" if PartidoDesf == ""

qui ta PartidoD, gen(P_)
qui ta Partido, gen(P_L_)


qui ta clave_mun, gen(muni_)
gen year_trend = year-2005

** create mun trends
egen Group_Mun= group(clave_mun)
egen Num_Mun = max(Group_Mun)
su Num_Mun
return list
forvalues x = 1/`r(mean)'{
	gen trend_`x' = muni_`x'*year_trend 
}




** Some controls at the state level (I'm not using this but it's useful for robustness)

gen codigo_estado = substr(clave_mun,1,2)
destring codigo_estado, replace

merge m:1 codigo_estado year using "$cd_data/Censo/Homicides_State.dta", gen(m_aux2)
merge m:1 codigo_estado year using "$cd_data/Censo/GDP_State.dta", gen(m_aux)
merge m:1 codigo_estado year using "$cd_data/Censo/Partido_State.dta", gen(m_aux3)

** Party at the state level (keep only have data on the 3 main parties, group the rest)
gen PartState =c
replace PartState = "OTROS" if !inlist(PartState, "PAN", "PRI", "PRD")
qui ta PartState, gen(Part_State_)


** Employment at the state level (not using it now but could be useful for robustness)

merge m:1 codigo_estado year using "$cd_data/Censo/Empleo_State.dta", gen(m_aux4)

******** PUBLIC OR PRIVATE SCHOOLS DATA

cap drop _merge
merge m:1 clavedelaescuela using "$cd_data/Censo/Escuelas_Pub_Priv.dta"

drop if _merge ==2
gen Privado = Publica_Privada == "PRIVADO"
gen missing = _merge ==1
gen inter_privado = Corrupt*Privado
gen inter_audit_privado =Auditada*Privado

******** TAX COLLECTION DATA

merge m:1 clave_mun year using  "$cd_data/Censo/Taxes_mun_2006_2013.dta", gen(m_taxes)
drop if m_taxes ==2
drop m_taxes


*** INTERACTIONS FOR CONTROL IN ANALYSIS OF HETEROGENEITY: normalize the controls (tax collection, homicides) and create the interactions with corruption and audit

qui sum total if total>0, meanonly
gen total_mean=total-`r(mean)'
replace total_mean = 0 if mis_tot==1
gen inter_total_mean_c=total_mean*Corrupt
gen inter_total_mean_c15=total_mean*Corrupt_15
gen inter_total_mean_c25=total_mean*Corrupt_25
gen inter_total_mean_clog=total_mean*ln_unau_center


gen inter_total_mean_a=total_mean*Auditada

qui sum HOMI_CAP_MUN , meanonly
gen HOMI_CAP_MUN_MEAN=HOMI_CAP_MUN-`r(mean)'
gen inter_homi_mean_c=HOMI_CAP_MUN_MEAN*Corrupt
gen inter_homi_mean_c15=HOMI_CAP_MUN_MEAN*Corrupt_15
gen inter_homi_mean_c25=HOMI_CAP_MUN_MEAN*Corrupt_25
gen inter_homi_mean_clog=HOMI_CAP_MUN_MEAN*ln_unau_center


gen inter_homi_mean_a=HOMI_CAP_MUN_MEAN*Auditada




*** MEDIA DATA

cap drop clave_loc
cap drop _merge
cap drop tasa_radio
gen clave_loc = clave_mun + loc

** Merge with local media data

merge m:1 clave_mun using "$cd_data/Censo/Radio_Emision2.dta"
replace cant = 0 if _merge ==1
drop if _merge ==2
drop _merge
merge m:1 clave_loc using  "$cd_data/Censo/Radio_Localidad.dta", force
drop if _merge ==2
cap drop Missing
gen Missing = (_merge ==1 | tasa_radio_missing==.)

drop _merge
replace tasa_radio_missing = 0 if Missing ==1

su tasa_radio_missing if Auditada ==1 & Missing ==0, de

** Median = .6256658   

* Define high demand of media as radio at home > median
gen AltaDemanda = tasa_radio_missing> .6256658         

** define supply media as the number of stations per capita (mun level)
gen tasa_oferta = cant*100000/pob_tot_int

** Take 1 if there is at least one radio station at the mun, 0 otherwise

gen RadiosPresent= tasa_oferta>0

su tasa_oferta,  de
*Median  1.119425 

gen AltaOferta = tasa_oferta>= 1.119425 

* High penetration of media: high demand in areas with at least 1 radio station
gen AltosBoth=RadiosPresent&AltaDemanda
* Create interactions with corruption and audit vars
gen inter_1=AltosBoth*Corrupt
gen inter_2=AltosBoth*Auditada
gen inter_3=AltaDemanda*Corrupt
gen inter_4=AltaDemanda*Auditada
gen inter_5=AltaOferta*Corrupt
gen inter_6=AltaOferta*Auditada
gen inter_1_15=AltosBoth*Corrupt_15
gen inter_1_25=AltosBoth*Corrupt_25
gen inter_1_log=AltosBoth*ln_unau

** create percentiles of media penetration for the graph


** Create quintiles of media penetration to gen the graph

cap drop Z
gen Z = tasa_radio_missing*RadiosPres

egen r = xtile(Z) if Missing ==0 & Z>0, nq(4)
replace r = 0 if Z ==0 & Missin ==0
ta r, gen(r_)


gen i_1=r_1*Corrupt
gen i_2=r_2*Corrupt
gen i_3=r_3*Corrupt
gen i_4=r_4*Corrupt
gen i_5=r_5*Corrupt

gen i_1_a=r_1*Auditada
gen i_2_a=r_2*Auditada
gen i_3_a=r_3*Auditada
gen i_4_a=r_4*Auditada
gen i_5_a=r_5*Auditada




** PERCEPTION OF CORRUPTION DATA


** This dataset contains the parties that were governing the municipalities, BUT now collapsed at the 3-main-national-parties-level (need to do this because perception data is at this level)

merge m:1 year clave_mun using  "$cd_data/Base Presidentes/Partidos_Alianzas.dta", gen(merge_PD)
keep if year<2014 & year >2005
keep if merge_PD !=2
ren winner winner_D
merge m:1 year clave_mun using  "$cd_data/Base Presidentes/Partidos_Alianzas_Hecho.dta", gen(merge_P)
keep if year<2014 & year >2005
keep if merge_P !=2

merge m:1 estado using "$cd_data/Censo/Percepcion_Corrupcion.dta", gen(mh)
gen PorcentajeCorrupto = PRI if winner == "PRI"
replace PorcentajeCorrupto = PAN if winner == "PAN"
replace PorcentajeCorrupto = PRD if winner == "PRD"


gen NotPriPanPrd = PorcentajeCorrupto ==.
ren NotPriPanPrd NO
replace Porcentaje = . if NO ==1
** Create an index of corruption perception from 0 to 1 depending on the % of people that consider the party in government corrupt
gen NormPerc= (Porcentaje-5)/(45.4)


replace Norm = 0 if Norm<0
** Define perceived corrupt as index >0.5
gen Mas50= Norm>= .5

replace Mas50=. if NO==1
** Create interactions
gen Inter_Mas50=Corrupt*Mas50
gen Inter_Audit=Auditada*Mas50
gen Inter_Mas50_15=Corrupt_15*Mas50
gen Inter_Mas50_25=Mas50*Corrupt_25
gen Inter_Mas50_log=Mas50*ln_unau_center


** Create a dummy indicating if the party at the state/mun levels are = to the party at national level
gen MismoPartidoState = 0

replace MismoPartidoState = 1 if PartS == winner
gen PartG = "PAN"
replace PartG= "PRI" if year>2012
gen MismoPartidoG = 0
replace MismoPartidoG = 1 if PartG == winner_D


replace MismoPartidoG = 1 if PartG == winner_D

** Create interactions (of same party national and local) with corruption and audit


gen inter_mismo_c=Corrupt*MismoPartidoG
gen inter_mismo_a=Auditada*MismoPartidoG

gen inter_ele=eleccion*Corrupt
gen inter_ele_a=eleccion*Auditada


** ELECTIONS AT THE STATE LEVEL DATA

** Get data on elections at state level. Then create the dummy for "election same year" and create the interactions with corruption and audit

merge m:1 ent year using "$cd_data/Base Presidentes/Elec_Estaduales.dta", gen(re) force
gen e_si=re==3
gen Eleccion_Same = MismoPartidoState* e_si
gen inter_Elec_Same= Corrupt*Eleccion_Same
gen inter_Elec_Same_Audit = Auditada*Eleccion_Same



qui ta year, gen(yy_)


*twoway rcap ci1 ci2 year || scatter main year , yline(0, lstyle(foreground)) xtitle("Effects by quintile") ytitle("Effect on Cheating")  graphregion(color(white)) ylab(,nogrid) legend(off) 
*graph save Graph "Graficos/Radio_quintiles.gph", replace
*graph export "Graficos/Radio_quintiles.pdf"



** GRAPHS KERNEL:: Figure A1

kdensity prop, title ("") yline(0, lstyle(foreground)) xtitle("") ytitle("")  graphregion(color(white)) ylab(,nogrid) bw(0.04)
graph save Graph "Graficos/Kernel_Cheating.gph", replace
graph export "Graficos/Kernel_Cheating.pdf", replace


save "$cd_data/to_run_db2.dta", replace
use "$cd_data/to_run_db2.dta", clear

*** FIGURES




** CORRUPTION - QUINTILES: FIGURE III 

*use "Users/Nico/Dropbox/Cheating in Mexico/Graficos/Grafico_Cuartiles.dta", clear
*use "Users/Nico/Dropbox/Cheating in Mexico/Graficos/Grafico_Cuartiles2.dta", clear


gen perc=0 if unau ==0

** I take these percentiles from the original municipality-year audit database (2006-2013).

replace perc =1 if inrange(unau,0.0000001, 2.7)
replace perc =2 if inrange(unau,2.70000001, 8.5)
replace perc =3 if inrange(unau,8.50000001, 18.4)
replace perc =4 if unau>18.4
ta perc, gen(CQ_)

areg prop CQ_2 CQ_3 CQ_4 CQ_5 grade_1 grade_2 Turn_* yy_* HOMI_CAP_MUN  total mis_tot P_* CorruptPast Already Auditada trend* MismoPartidoG,  absorb(clavedelae) cluster(clave_mun)


** FIGURE 3

cap drop coef_perc ci1 ci2
* Genarate coefficient of scatter
gen coef_perc = .
replace coef_perc = _b[CQ_2]*100 if perc == 1
replace coef_perc = _b[CQ_3]*100 if perc == 2
replace coef_perc = _b[CQ_4]*100 if perc == 3
replace coef_perc = _b[CQ_5]*100 if perc == 4

* Generate lower ci (ci1)
gen ci1 = .
replace ci1 = _b[CQ_2]*100 - 1.96*_se[CQ_2]*100 if perc == 1 
replace ci1 = _b[CQ_3]*100 - 1.96*_se[CQ_3]*100 if perc == 2
replace ci1 = _b[CQ_4]*100 - 1.96*_se[CQ_4]*100 if perc == 3
replace ci1 = _b[CQ_5]*100 - 1.96*_se[CQ_5]*100 if perc == 4

* Generate upper ci (ci2)
gen ci2 = .
replace ci2 = _b[CQ_2]*100 + 1.96*_se[CQ_2]*100 if perc == 1 
replace ci2 = _b[CQ_3]*100 + 1.96*_se[CQ_3]*100 if perc == 2
replace ci2 = _b[CQ_4]*100 + 1.96*_se[CQ_4]*100 if perc == 3
replace ci2 = _b[CQ_5]*100 + 1.96*_se[CQ_5]*100 if perc == 4

twoway rcap ci1 ci2 perc if inrange(perc, 1, 4) , legend(off) || scatter coef_perc perc if inrange(perc, 1, 4), yline(0, lstyle(foreground)) xtitle("Effects by quartile") ytitle("Effect on Cheating")  graphregion(color(white)) ylab(,nogrid) legend(off) 
graph save Graph "Graficos/Figure3.gph", replace
graph export "Graficos/Figure3.pdf", replace

cap drop coef_perc ci1 ci2

replace prop = prop*100
******* TABLES 
cap log close
log using "Tables/Table1.txt", text replace

** Main Specification with and without controls, with FE
** TABLE 1

areg prop Corrupt grade_1 grade_2 Turn_* yy_* HOMI_CAP_MUN  total mis_tot P_* CorruptPast Already Auditada trend* MismoPartidoG,  absorb(clavedelae) cluster(clave_mun)
areg prop Corrupt grade_1 grade_2 Turn_* yy_* HOMI_CAP_MUN  total mis_tot CorruptPast Already Auditada P_* MismoPartidoG,  absorb(clavedelae) cluster(clave_mun)
areg prop Corrupt Turn_* yy_* HOMI_CAP_MUN  total mis_tot CorruptPast Already Auditada P_* MismoPartidoG,  absorb(clavedelae) cluster(clave_mun)
areg prop Corrupt Turn_* yy_*  Auditada P_*,  absorb(clavedelae) cluster(clave_mun)
areg prop Corrupt Turn_* yy_*  Auditada,  absorb(clavedelae) cluster(clave_mun)

cap log close

cap log close
log using "Tables/Table2.txt", text replace
** Robust with thresholds
** TABLE 2

areg prop Corrupt_15 grade_1 grade_2 Turn_* yy_* HOMI_CAP_MUN  total mis_tot P_* CorruptPast_15 Already Auditada trend* MismoPartidoG,  absorb(clavedelae) cluster(clave_mun)
areg prop Corrupt_15 grade_1 grade_2 Turn_* yy_* HOMI_CAP_MUN  total mis_tot CorruptPast_15 Already Auditada P_* MismoPartidoG,  absorb(clavedelae) cluster(clave_mun)
areg prop Corrupt_15 Turn_* yy_* HOMI_CAP_MUN  total mis_tot CorruptPast_15 Already Auditada P_* MismoPartidoG,  absorb(clavedelae) cluster(clave_mun)
*areg prop Corrupt_15 Turn_* yy_*  Auditada P_*,  absorb(clavedelae) cluster(clave_mun)
areg prop Corrupt_15 Turn_* yy_*  Auditada,  absorb(clavedelae) cluster(clave_mun)

areg prop Corrupt_25 grade_1 grade_2 Turn_* yy_* HOMI_CAP_MUN  total mis_tot P_* CorruptPast_25 Already Auditada trend* MismoPartidoG,  absorb(clavedelae) cluster(clave_mun)
areg prop Corrupt_25 grade_1 grade_2 Turn_* yy_* HOMI_CAP_MUN  total mis_tot CorruptPast_25 Already Auditada P_* MismoPartidoG,  absorb(clavedelae) cluster(clave_mun)
areg prop Corrupt_25 Turn_* yy_* HOMI_CAP_MUN  total mis_tot CorruptPast_25 Already Auditada P_* MismoPartidoG,  absorb(clavedelae) cluster(clave_mun)
*areg prop Corrupt_25 Turn_* yy_*  Auditada P_*,  absorb(clavedelae) cluster(clave_mun)
areg prop Corrupt_25 Turn_* yy_*  Auditada,  absorb(clavedelae) cluster(clave_mun)


areg prop ln_unau grade_1 grade_2 Turn_* yy_* HOMI_CAP_MUN  total mis_tot P_* CorruptPast Already Auditada trend* MismoPartidoG,  absorb(clavedelae) cluster(clave_mun)
areg prop ln_unau grade_1 grade_2 Turn_* yy_* HOMI_CAP_MUN  total mis_tot CorruptPast Already Auditada P_* MismoPartidoG,  absorb(clavedelae) cluster(clave_mun)
areg prop ln_unau Turn_* yy_* HOMI_CAP_MUN  total mis_tot CorruptPast Already Auditada P_* MismoPartidoG,  absorb(clavedelae) cluster(clave_mun)
*areg prop ln_unau Turn_* yy_*  Auditada P_*,  absorb(clavedelae) cluster(clave_mun)
areg prop ln_unau Turn_* yy_*  Auditada,  absorb(clavedelae) cluster(clave_mun)



areg prop Corrupt grade_1 grade_2 Turn_* yy_* HOMI_CAP_MUN  total mis_tot P_* CorruptPast Already Auditada trend* MismoPartidoG,  absorb(clave_mun) cluster(clave_mun)
areg prop Corrupt_15 grade_1 grade_2 Turn_* yy_* HOMI_CAP_MUN  total mis_tot P_* CorruptPast_15 Already Auditada trend* MismoPartidoG,  absorb(clave_mun) cluster(clave_mun)
areg prop Corrupt_25 grade_1 grade_2 Turn_* yy_* HOMI_CAP_MUN  total mis_tot P_* CorruptPast_25 Already Auditada trend* MismoPartidoG,  absorb(clave_mun) cluster(clave_mun)
areg prop ln_unau grade_1 grade_2 Turn_* yy_* HOMI_CAP_MUN  total mis_tot P_* CorruptPast Already Auditada trend* MismoPartidoG,  absorb(clave_mun) cluster(clave_mun)


areg prop Corrupt grade_1 grade_2 Turn_* yy_* HOMI_CAP_MUN  total mis_tot P_* CorruptPast Already Auditada MismoPartidoG if Auditada ==1,  absorb(clavedela) cluster(clave_mun)
areg prop Corrupt_15 grade_1 grade_2 Turn_* yy_* HOMI_CAP_MUN  total mis_tot P_* CorruptPast_15 Already Auditada  MismoPartidoG if Auditada ==1,  absorb(clavedela) cluster(clave_mun)
areg prop Corrupt_25 grade_1 grade_2 Turn_* yy_* HOMI_CAP_MUN  total mis_tot P_* CorruptPast_25 Already Auditada MismoPartidoG if Auditada ==1,  absorb(clavedela) cluster(clave_mun)
areg prop ln_unau grade_1 grade_2 Turn_* yy_* HOMI_CAP_MUN  total mis_tot P_* CorruptPast Already Auditada  MismoPartidoG if Auditada ==1,  absorb(clavedela) cluster(clave_mun)

cap log close



*** LEADS AND LAGS WITH AND WITHOUT CONTROLS


** Here's a model: twoway rcap ci1 ci2 year || scatter main year, yline(0, lstyle(foreground)) xtitle("Effects by quartile") ytitle("Effect on Cheating")  graphregion(color(white)) ylab(,nogrid)

replace prop = prop/100
* FIGURE IV (main) and 

areg prop  C_1 C_2 Corrupt C_menos1 C_menos2  grade_1 grade_2   Turn_* yy_* HOMI_CAP_MUN  total mis_tot P_* CorruptPast Already Auditada trend* lag_Auditada1 lag_Auditada2 lead_Auditada1 lead_Auditada2 MismoPartidoG,  absorb(clavedelae) cluster(clave_mun)

* Graph Code
matrix B = (-2,.,.,.\-1,0,.,.\0,.,.,.\1,.,.,.\2,.,.,.)
* b(-2)
lincom C_2-C_1, level(95)
matrix B[1,2] = r(estimate)*100
matrix B[1,3] = r(estimate)*100 - 1.96*r(se)*100
matrix B[1,4] = r(estimate)*100 + 1.96*r(se)*100
* b(-1) = 0
* b(0)
lincom Corrupt-C_1, level(95)
matrix B[3,2] = r(estimate)*100
matrix B[3,3] = r(estimate)*100 - 1.96*r(se)*100
matrix B[3,4] = r(estimate)*100 + 1.96*r(se)*100
* b(1)
lincom C_menos1 - C_1, level(95)
matrix B[4,2] = r(estimate)*100
matrix B[4,3] = r(estimate)*100 - 1.96*r(se)*100
matrix B[4,4] = r(estimate)*100 + 1.96*r(se)*100
* b(2)
lincom C_menos2 - C_1, level(95)
matrix B[5,2] = r(estimate)*100
matrix B[5,3] = r(estimate)*100 - 1.96*r(se)*100
matrix B[5,4] = r(estimate)*100 + 1.96*r(se)*100
mat list B
svmat B
cap drop time coef_es ci1 ci2
rename B1 time
rename B2 coef_es
rename B3 ci1
rename B4 ci2

twoway rcap ci1 ci2 time if time !=. , legend(off) || scatter coef_es time if time !=., yline(0, lstyle(foreground)) xtitle("Period of Corruption Detection") ytitle("Effect on Cheating")  graphregion(color(white)) ylab(,nogrid) legend(off) 
graph save Graph "Graficos/Figure4.gph", replace
graph export "Graficos/Figure4.pdf", replace

cap drop time coef_es ci1 ci2


* FIGURE A3 (robust)

// Model 4
areg prop  C_1 C_2 Corrupt C_menos1 C_menos2 grade_1 grade_2   Turn_* yy_* HOMI_CAP_MUN  total mis_tot P_* CorruptPast Already Auditada lag_Auditada1 lag_Auditada2 lead_Auditada1 lead_Auditada2 MismoPartidoG,  absorb(clavedelae) cluster(clave_mun)

* Graph Code
matrix B = (-2,.,.,.\-1,0,.,.\0,.,.,.\1,.,.,.\2,.,.,.)
* b(-2)
lincom C_2-C_1, level(95)
matrix B[1,2] = r(estimate)*100
matrix B[1,3] = r(estimate)*100 - 1.96*r(se)*100
matrix B[1,4] = r(estimate)*100 + 1.96*r(se)*100
* b(-1) = 0
* b(0)
lincom Corrupt-C_1, level(95)
matrix B[3,2] = r(estimate)*100
matrix B[3,3] = r(estimate)*100 - 1.96*r(se)*100
matrix B[3,4] = r(estimate)*100 + 1.96*r(se)*100
* b(1)
lincom C_menos1 - C_1, level(95)
matrix B[4,2] = r(estimate)*100
matrix B[4,3] = r(estimate)*100 - 1.96*r(se)*100
matrix B[4,4] = r(estimate)*100 + 1.96*r(se)*100
* b(2)
lincom C_menos2 - C_1, level(95)
matrix B[5,2] = r(estimate)*100
matrix B[5,3] = r(estimate)*100 - 1.96*r(se)*100
matrix B[5,4] = r(estimate)*100 + 1.96*r(se)*100
mat list B
svmat B
cap drop time coef_es ci1 ci2
rename B1 time
rename B2 coef_es
rename B3 ci1
rename B4 ci2

twoway rcap ci1 ci2 time if time !=. , legend(off) || scatter coef_es time if time !=., title("Model (4)") yline(0, lstyle(foreground)) xtitle("Period of Corruption Detection") ytitle("Effect on Cheating")  graphregion(color(white)) ylab(,nogrid) legend(off) 
graph save Graph "Graficos/FigureA3_4.gph", replace
graph export "Graficos/FigureA3_4.pdf", replace

cap drop time coef_es ci1 ci2

// Model 3
areg prop  C_1 C_2 Corrupt C_menos1 C_menos2  yy_* HOMI_CAP_MUN  total mis_tot P_* CorruptPast Already Auditada lag_Auditada1 lag_Auditada2 lead_Auditada1 lead_Auditada2 MismoPartidoG,  absorb(clavedelae) cluster(clave_mun)

* Graph Code
matrix B = (-2,.,.,.\-1,0,.,.\0,.,.,.\1,.,.,.\2,.,.,.)
* b(-2)
lincom C_2-C_1, level(95)
matrix B[1,2] = r(estimate)*100
matrix B[1,3] = r(estimate)*100 - 1.96*r(se)*100
matrix B[1,4] = r(estimate)*100 + 1.96*r(se)*100
* b(-1) = 0
* b(0)
lincom Corrupt-C_1, level(95)
matrix B[3,2] = r(estimate)*100
matrix B[3,3] = r(estimate)*100 - 1.96*r(se)*100
matrix B[3,4] = r(estimate)*100 + 1.96*r(se)*100
* b(1)
lincom C_menos1 - C_1, level(95)
matrix B[4,2] = r(estimate)*100
matrix B[4,3] = r(estimate)*100 - 1.96*r(se)*100
matrix B[4,4] = r(estimate)*100 + 1.96*r(se)*100
* b(2)
lincom C_menos2 - C_1, level(95)
matrix B[5,2] = r(estimate)*100
matrix B[5,3] = r(estimate)*100 - 1.96*r(se)*100
matrix B[5,4] = r(estimate)*100 + 1.96*r(se)*100
mat list B
svmat B
cap drop time coef_es ci1 ci2
rename B1 time
rename B2 coef_es
rename B3 ci1
rename B4 ci2

twoway rcap ci1 ci2 time if time !=. , legend(off) || scatter coef_es time if time !=., title("Model (3)") yline(0, lstyle(foreground)) xtitle("Period of Corruption Detection") ytitle("Effect on Cheating")  graphregion(color(white)) ylab(,nogrid) legend(off) 
graph save Graph "Graficos/FigureA3_3.gph", replace
graph export "Graficos/FigureA3_3.pdf", replace

cap drop time coef_es ci1 ci2

// Model 2
areg prop  C_1 C_2 Corrupt C_menos1 C_menos2 yy*  Turn_* yy_*  P_*  Auditada lag_Auditada1 lag_Auditada2 lead_Auditada1 lead_Auditada2 MismoPartidoG,  absorb(clavedelae) cluster(clave_mun)

* Graph Code
matrix B = (-2,.,.,.\-1,0,.,.\0,.,.,.\1,.,.,.\2,.,.,.)
* b(-2)
lincom C_2-C_1, level(95)
matrix B[1,2] = r(estimate)*100
matrix B[1,3] = r(estimate)*100 - 1.96*r(se)*100
matrix B[1,4] = r(estimate)*100 + 1.96*r(se)*100
* b(-1) = 0
* b(0)
lincom Corrupt-C_1, level(95)
matrix B[3,2] = r(estimate)*100
matrix B[3,3] = r(estimate)*100 - 1.96*r(se)*100
matrix B[3,4] = r(estimate)*100 + 1.96*r(se)*100
* b(1)
lincom C_menos1 - C_1, level(95)
matrix B[4,2] = r(estimate)*100
matrix B[4,3] = r(estimate)*100 - 1.96*r(se)*100
matrix B[4,4] = r(estimate)*100 + 1.96*r(se)*100
* b(2)
lincom C_menos2 - C_1, level(95)
matrix B[5,2] = r(estimate)*100
matrix B[5,3] = r(estimate)*100 - 1.96*r(se)*100
matrix B[5,4] = r(estimate)*100 + 1.96*r(se)*100
mat list B
svmat B
cap drop time coef_es ci1 ci2
rename B1 time
rename B2 coef_es
rename B3 ci1
rename B4 ci2

twoway rcap ci1 ci2 time if time !=. , legend(off) || scatter coef_es time if time !=., title("Model (2)") yline(0, lstyle(foreground)) xtitle("Period of Corruption Detection") ytitle("Effect on Cheating")  graphregion(color(white)) ylab(,nogrid) legend(off) 
graph save Graph "Graficos/FigureA3_2.gph", replace
graph export "Graficos/FigureA3_2.pdf", replace

cap drop time coef_es ci1 ci2

// Model 1
areg prop  C_1 C_2 Corrupt C_menos1 C_menos2 yy*  Turn_* yy_*   Auditada lag_Auditada1 lag_Auditada2 lead_Auditada1 lead_Auditada2 MismoPartidoG,  absorb(clavedelae) cluster(clave_mun)

* Graph Code
matrix B = (-2,.,.,.\-1,0,.,.\0,.,.,.\1,.,.,.\2,.,.,.)
* b(-2)
lincom C_2-C_1, level(95)
matrix B[1,2] = r(estimate)*100
matrix B[1,3] = r(estimate)*100 - 1.96*r(se)*100
matrix B[1,4] = r(estimate)*100 + 1.96*r(se)*100
* b(-1) = 0
* b(0)
lincom Corrupt-C_1, level(95)
matrix B[3,2] = r(estimate)*100
matrix B[3,3] = r(estimate)*100 - 1.96*r(se)*100
matrix B[3,4] = r(estimate)*100 + 1.96*r(se)*100
* b(1)
lincom C_menos1 - C_1, level(95)
matrix B[4,2] = r(estimate)*100
matrix B[4,3] = r(estimate)*100 - 1.96*r(se)*100
matrix B[4,4] = r(estimate)*100 + 1.96*r(se)*100
* b(2)
lincom C_menos2 - C_1, level(95)
matrix B[5,2] = r(estimate)*100
matrix B[5,3] = r(estimate)*100 - 1.96*r(se)*100
matrix B[5,4] = r(estimate)*100 + 1.96*r(se)*100
mat list B
svmat B
cap drop time coef_es ci1 ci2
rename B1 time
rename B2 coef_es
rename B3 ci1
rename B4 ci2

twoway rcap ci1 ci2 time if time !=. , legend(off) || scatter coef_es time if time !=.,title("Model (1)") yline(0, lstyle(foreground)) xtitle("Period of Corruption Detection") ytitle("Effect on Cheating")  graphregion(color(white)) ylab(,nogrid) legend(off) 
graph save Graph "Graficos/FigureA3_1.gph", replace
graph export "Graficos/FigureA3_1.pdf", replace

cap drop time coef_es ci1 ci2


graph combine "Graficos/FigureA3_1.gph" "Graficos/FigureA3_2.gph" "Graficos/FigureA3_3.gph" "Graficos/FigureA3_4.gph", graphregion(color(white))
graph save Graph "Graficos/FigureA3.gph", replace
graph export "Graficos/FigureA3.pdf", replace


** ONLY AUDITED: FIGURE A4


// Model 4
areg prop  C_1 C_2 Corrupt C_menos1 C_menos2 grade_1 grade_2   Turn_* yy_* HOMI_CAP_MUN  total mis_tot P_* CorruptPast Already    MismoPartidoG if Auditada ==1,  absorb(clavedelae) cluster(clave_mun)

* Graph Code
matrix B = (-2,.,.,.\-1,0,.,.\0,.,.,.\1,.,.,.\2,.,.,.)
* b(-2)
lincom C_2-C_1, level(95)
matrix B[1,2] = r(estimate)*100
matrix B[1,3] = r(estimate)*100 - 1.96*r(se)*100
matrix B[1,4] = r(estimate)*100 + 1.96*r(se)*100
* b(-1) = 0
* b(0)
lincom Corrupt-C_1, level(95)
matrix B[3,2] = r(estimate)*100
matrix B[3,3] = r(estimate)*100 - 1.96*r(se)*100
matrix B[3,4] = r(estimate)*100 + 1.96*r(se)*100
* b(1)
lincom C_menos1 - C_1, level(95)
matrix B[4,2] = r(estimate)*100
matrix B[4,3] = r(estimate)*100 - 1.96*r(se)*100
matrix B[4,4] = r(estimate)*100 + 1.96*r(se)*100
* b(2)
lincom C_menos2 - C_1, level(95)
matrix B[5,2] = r(estimate)*100
matrix B[5,3] = r(estimate)*100 - 1.96*r(se)*100
matrix B[5,4] = r(estimate)*100 + 1.96*r(se)*100
mat list B
svmat B
cap drop time coef_es ci1 ci2
rename B1 time
rename B2 coef_es
rename B3 ci1
rename B4 ci2

twoway rcap ci1 ci2 time if time !=. , legend(off) || scatter coef_es time if time !=., title("Model (4)") yline(0, lstyle(foreground)) xtitle("Period of Corruption Detection") ytitle("Effect on Cheating")  graphregion(color(white)) ylab(,nogrid) legend(off) 
graph save Graph "Graficos/FigureA4_4.gph", replace
graph export "Graficos/FigureA4_4.pdf", replace

cap drop time coef_es ci1 ci2

// Model 3
areg prop  C_1 C_2 Corrupt C_menos1 C_menos2  yy_* HOMI_CAP_MUN  total mis_tot P_* CorruptPast Already   MismoPartidoG if Auditada ==1,  absorb(clavedelae) cluster(clave_mun)

* Graph Code
matrix B = (-2,.,.,.\-1,0,.,.\0,.,.,.\1,.,.,.\2,.,.,.)
* b(-2)
lincom C_2-C_1, level(95)
matrix B[1,2] = r(estimate)*100
matrix B[1,3] = r(estimate)*100 - 1.96*r(se)*100
matrix B[1,4] = r(estimate)*100 + 1.96*r(se)*100
* b(-1) = 0
* b(0)
lincom Corrupt-C_1, level(95)
matrix B[3,2] = r(estimate)*100
matrix B[3,3] = r(estimate)*100 - 1.96*r(se)*100
matrix B[3,4] = r(estimate)*100 + 1.96*r(se)*100
* b(1)
lincom C_menos1 - C_1, level(95)
matrix B[4,2] = r(estimate)*100
matrix B[4,3] = r(estimate)*100 - 1.96*r(se)*100
matrix B[4,4] = r(estimate)*100 + 1.96*r(se)*100
* b(2)
lincom C_menos2 - C_1, level(95)
matrix B[5,2] = r(estimate)*100
matrix B[5,3] = r(estimate)*100 - 1.96*r(se)*100
matrix B[5,4] = r(estimate)*100 + 1.96*r(se)*100
mat list B
svmat B
cap drop time coef_es ci1 ci2
rename B1 time
rename B2 coef_es
rename B3 ci1
rename B4 ci2

twoway rcap ci1 ci2 time if time !=. , legend(off) || scatter coef_es time if time !=., title("Model (3)") yline(0, lstyle(foreground)) xtitle("Period of Corruption Detection") ytitle("Effect on Cheating")  graphregion(color(white)) ylab(,nogrid) legend(off) 
graph save Graph "Graficos/FigureA4_3.gph", replace
graph export "Graficos/FigureA4_3.pdf", replace

cap drop time coef_es ci1 ci2

// Model 2
areg prop  C_1 C_2 Corrupt C_menos1 C_menos2 yy*  Turn_* yy_*  P_*   MismoPartidoG if Auditada ==1,  absorb(clavedelae) cluster(clave_mun)

* Graph Code
matrix B = (-2,.,.,.\-1,0,.,.\0,.,.,.\1,.,.,.\2,.,.,.)
* b(-2)
lincom C_2-C_1, level(95)
matrix B[1,2] = r(estimate)*100
matrix B[1,3] = r(estimate)*100 - 1.96*r(se)*100
matrix B[1,4] = r(estimate)*100 + 1.96*r(se)*100
* b(-1) = 0
* b(0)
lincom Corrupt-C_1, level(95)
matrix B[3,2] = r(estimate)*100
matrix B[3,3] = r(estimate)*100 - 1.96*r(se)*100
matrix B[3,4] = r(estimate)*100 + 1.96*r(se)*100
* b(1)
lincom C_menos1 - C_1, level(95)
matrix B[4,2] = r(estimate)*100
matrix B[4,3] = r(estimate)*100 - 1.96*r(se)*100
matrix B[4,4] = r(estimate)*100 + 1.96*r(se)*100
* b(2)
lincom C_menos2 - C_1, level(95)
matrix B[5,2] = r(estimate)*100
matrix B[5,3] = r(estimate)*100 - 1.96*r(se)*100
matrix B[5,4] = r(estimate)*100 + 1.96*r(se)*100
mat list B
svmat B
cap drop time coef_es ci1 ci2
rename B1 time
rename B2 coef_es
rename B3 ci1
rename B4 ci2

twoway rcap ci1 ci2 time if time !=. , legend(off) || scatter coef_es time if time !=., title("Model (2)") yline(0, lstyle(foreground)) xtitle("Period of Corruption Detection") ytitle("Effect on Cheating")  graphregion(color(white)) ylab(,nogrid) legend(off) 
graph save Graph "Graficos/FigureA4_2.gph", replace
graph export "Graficos/FigureA4_2.pdf", replace

cap drop time coef_es ci1 ci2

// Model 1
areg prop  C_1 C_2 Corrupt C_menos1 C_menos2 yy*  Turn_* yy_*   MismoPartidoG if Auditada ==1,  absorb(clavedelae) cluster(clave_mun)

* Graph Code
matrix B = (-2,.,.,.\-1,0,.,.\0,.,.,.\1,.,.,.\2,.,.,.)
* b(-2)
lincom C_2-C_1, level(95)
matrix B[1,2] = r(estimate)*100
matrix B[1,3] = r(estimate)*100 - 1.96*r(se)*100
matrix B[1,4] = r(estimate)*100 + 1.96*r(se)*100
* b(-1) = 0
* b(0)
lincom Corrupt-C_1, level(95)
matrix B[3,2] = r(estimate)*100
matrix B[3,3] = r(estimate)*100 - 1.96*r(se)*100
matrix B[3,4] = r(estimate)*100 + 1.96*r(se)*100
* b(1)
lincom C_menos1 - C_1, level(95)
matrix B[4,2] = r(estimate)*100
matrix B[4,3] = r(estimate)*100 - 1.96*r(se)*100
matrix B[4,4] = r(estimate)*100 + 1.96*r(se)*100
* b(2)
lincom C_menos2 - C_1, level(95)
matrix B[5,2] = r(estimate)*100
matrix B[5,3] = r(estimate)*100 - 1.96*r(se)*100
matrix B[5,4] = r(estimate)*100 + 1.96*r(se)*100
mat list B
svmat B
cap drop time coef_es ci1 ci2
rename B1 time
rename B2 coef_es
rename B3 ci1
rename B4 ci2

twoway rcap ci1 ci2 time if time !=. , legend(off) || scatter coef_es time if time !=., title("Model (1)") yline(0, lstyle(foreground)) xtitle("Period of Corruption Detection") ytitle("Effect on Cheating")  graphregion(color(white)) ylab(,nogrid) legend(off) 
graph save Graph "Graficos/FigureA4_1.gph", replace
graph export "Graficos/FigureA4_1.pdf", replace

cap drop time coef_es ci1 ci2


graph combine "Graficos/FigureA4_1.gph" "Graficos/FigureA4_2.gph" "Graficos/FigureA4_3.gph" "Graficos/FigureA4_4.gph", graphregion(color(white))
graph save Graph "Graficos/FigureA4.gph", replace
graph export "Graficos/FigureA4.pdf", replace




**** INTERACTION WITH MEDIA
cap log close
replace prop = prop*100
log using "Tables/Table6.txt", text replace

** TABLE VI columns 1 and 2

areg prop Corrupt inter_1 AltosBoth inter_mismo_c inter_mismo_a MismoPartidoG   inter_2 inter_total_mean_c inter_total_mean_a Already CorruptPast Auditada grade_1 grade_2 Turn_* yy_* total  HOMI_CAP_MUN inter_homi_mean_c inter_homi_mean_a mis_tot P_* trend*,  absorb(clavedelae) cluster(clave_mun)
lincom Corrupt+inter_1
areg prop Corrupt inter_1 AltosBoth inter_mismo_c inter_mismo_a MismoPartidoG   inter_2 inter_total_mean_c inter_total_mean_a Auditada yy_*,  absorb(clavedelae) cluster(clave_mun)
lincom Corrupt+inter_1


** TABLE VI columns 3 and 4
**** INTERACTION WITH POLITICS

areg prop Corrupt Inter_Mas50 inter_mismo_c inter_mismo_a MismoPartidoG  Mas50 inter_mismo_c inter_mismo_a MismoPartidoG   Inter_Audit inter_total_mean_c inter_total_mean_a Already CorruptPast Auditada grade_1 grade_2 Turn_* yy_* total  HOMI_CAP_MUN inter_homi_mean_c inter_homi_mean_a mis_tot P_* trend*,  absorb(clavedelae) cluster(clave_mun)
lincom Corrupt+Inter_Mas50 
areg prop Corrupt Inter_Mas50 inter_mismo_c inter_mismo_a MismoPartidoG  Mas50 inter_mismo_c inter_mismo_a MismoPartidoG   Inter_Audit inter_total_mean_c inter_total_mean_a Auditada yy_*,  absorb(clavedelae) cluster(clave_mun)
lincom Corrupt+Inter_Mas50 

cap log close



** Main Specification with PRIVATE INTERACTION

cap log close
log using "Tables/Table7.txt", text replace

** TABLE VII columns 1 and 2

areg prop Corrupt inter_privado inter_audit_privado inter_mismo_c inter_mismo_a inter_total_mean_c inter_total_mean_a inter_homi_mean_c inter_homi_mean_a Turn_* yy_*  Auditada,  absorb(clavedelae) cluster(clave_mun)
lincom Corrupt+inter_privado

areg prop Corrupt inter_privado inter_audit_privado inter_mismo_c inter_mismo_a inter_total_mean_c inter_total_mean_a inter_homi_mean_c inter_homi_mean_a  grade_1 grade_2 Turn_* yy_* HOMI_CAP_MUN  total mis_tot P_* CorruptPast Already Auditada trend* MismoPartidoG,  absorb(clavedelae) cluster(clave_mun)
lincom Corrupt+inter_privado


*** RULE OUT GRADE INFLATION
** TABLE VII columns 3 and 4

areg prop Corrupt inter_ele inter_ele_a eleccion MismoPartidoG    inter_total_mean_c inter_total_mean_a Auditada yy_* if MismoPartidoS==1 ,  absorb(clavedelae) cluster(clave_mun)
lincom Corrupt+inter_ele

areg prop Corrupt inter_ele inter_ele_a eleccion MismoPartidoG    inter_total_mean_c inter_total_mean_a Already CorruptPast Auditada grade_1 grade_2 Turn_* yy_* total  HOMI_CAP_MUN inter_homi_mean_c inter_homi_mean_a mis_tot P_* trend* if MismoPartidoS==1,  absorb(clavedelae) cluster(clave_mun)
lincom Corrupt+inter_ele


*** INTERACTION WITH CLASS SIZE
** TABLE VII columns 5 and 6

areg prop Corrupt i_b ln_big_center inter_mismo_c inter_mismo_a MismoPartidoG   i_a inter_total_mean_c inter_total_mean_a Auditada yy_*,  absorb(clavedelae) cluster(clave_mun)
lincom Corrupt+i_b


areg prop Corrupt i_b ln_big_center inter_mismo_c inter_mismo_a MismoPartidoG   i_a inter_total_mean_c inter_total_mean_a Already CorruptPast Auditada grade_1 grade_2 Turn_* yy_* total  HOMI_CAP_MUN inter_homi_mean_c inter_homi_mean_a mis_tot P_* trend*,  absorb(clavedelae) cluster(clave_mun)
lincom Corrupt+i_b

cap log close


** FIGURE VI
replace prop = prop/100

areg prop i_1* i_2* i_3* i_4* i_5* grade_1 grade_2 Turn_* yy_* HOMI_CAP_MUN  total mis_tot P_* CorruptPast Already Auditada trend* MismoPartidoG,  absorb(clavedelae) cluster(clave_mun)

* Graph Code

matrix B = (1,.,.,.\2,.,.,.\3,.,.,.\4,.,.,.\5,.,.,.)

* Generate coef_i
matrix B[1,2] = _b[i_1]*100
matrix B[2,2] = _b[i_2]*100
matrix B[3,2] = _b[i_3]*100
matrix B[4,2] = _b[i_4]*100
matrix B[5,2] = _b[i_5]*100

* Generate lower ci (ci1)
matrix B[1,3] = _b[i_1]*100 - 1.96*_se[i_1]*100
matrix B[2,3] = _b[i_2]*100 - 1.96*_se[i_2]*100
matrix B[3,3] = _b[i_3]*100 - 1.96*_se[i_3]*100
matrix B[4,3] = _b[i_4]*100 - 1.96*_se[i_4]*100
matrix B[5,3] = _b[i_5]*100 - 1.96*_se[i_5]*100

* Generate upper ci (ci2)
matrix B[1,4] = _b[i_1]*100 + 1.96*_se[i_1]*100
matrix B[2,4] = _b[i_2]*100 + 1.96*_se[i_2]*100
matrix B[3,4] = _b[i_3]*100 + 1.96*_se[i_3]*100
matrix B[4,4] = _b[i_4]*100 + 1.96*_se[i_4]*100
matrix B[5,4] = _b[i_5]*100 + 1.96*_se[i_5]*100

mat list B
svmat B
cap drop quintile coef_i ci1 ci2
rename B1 quintile
rename B2 coef_i
rename B3 ci1
rename B4 ci2


twoway rcap ci1 ci2 quintile if quintile !=. , legend(off) || scatter coef_i quintile if quintile !=., yline(0, lstyle(foreground)) xtitle("Effects by quintile") ytitle("Effect on Cheating")  graphregion(color(white)) ylab(,nogrid) legend(off)

graph save Graph "Graficos/Figure6.gph", replace
graph export "Graficos/Figure6.pdf", replace




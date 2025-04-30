*********************** PART I: prepare the values data for analysis ***********************
*** Use the relevant modules of the survey at the hh level and individual level


*** 2009: households (id: folio)

use "$cd_data/Longitudinal/2009/Hogares/c_portad.dta", clear

merge 1:1 folio using "$cd_data/Longitudinal/2009/Hogares/c_cv.dta",
drop _m

merge 1:1 folio using "$cd_data/Longitudinal/2009/Hogares/c_cvo.dta",
drop _m

merge 1:1 folio using "$cd_data/Longitudinal/2009/Hogares/c_ne.dta",
drop _m

merge 1:1 folio using "$cd_data/Longitudinal/2009/Hogares/c_rc.dta",
drop _m

merge 1:m folio using "$cd_data/Longitudinal/2009/Hogares/Fechas.dta",
drop _m

**** 2009: individuals (id:folio or pid_link)

merge 1:m folio using "$cd_data/Longitudinal/2009/Individuos/iiia_ee.dta",
keep if _m ==3
drop _m

merge 1:1 pid_link using "$cd_data/Longitudinal/2009/Individuos/iiia_ah.dta",
keep if _m ==3
drop _m

merge 1:1 pid_link using "$cd_data/Longitudinal/2009/Individuos/iiia_ed.dta",
keep if _m ==3
drop _m

merge 1:1 pid_link using "$cd_data/Longitudinal/2009/Individuos/iiia_iin.dta",
keep if _m ==3
drop _m

merge 1:1 pid_link using "$cd_data/Longitudinal/2009/Individuos/iiia_tb.dta",
keep if _m ==3
drop _m

merge 1:1 pid_link using "$cd_data/Longitudinal/2009/Individuos/iiib_rg.dta",
keep if _m !=2
drop _m

merge 1:1 pid_link using "$cd_data/Longitudinal/2009/Individuos/iiib_co.dta",
keep if _m !=2
drop _m


merge 1:1 pid_link using "$cd_data/Longitudinal/2009/Individuos/iiia_mg.dta",
keep if _m !=2
drop _m

merge 1:1 pid_link using "$cd_data/Longitudinal/2009/Individuos/iiia_ata.dta",
keep if _m !=2
drop _m

merge 1:1 pid_link using "$cd_data/Longitudinal/2009/Individuos/iiib_sm.dta",
drop _m

merge 1:1 pid_link using "$cd_data/Longitudinal/2009/Individuos/iiib_pr.dta",
drop _m

merge 1:1 pid_link using "$cd_data/Longitudinal/2009/Individuos/iiia_vli.dta",
drop _m

merge 1:1 pid_link using "$cd_data/Longitudinal/2009/Individuos/iiia_shi.dta"
drop _m
tostring mpio, gen(mpioS)
tostring ent, gen (entS)
replace entS = "0"+entS if ent <10
replace mpioS = "00" + mpioS if mpio<10
replace mpioS = "0" + mpioS if mpio>=10 & mpio <100
gen clave_mun = entS+mpioS


gen p = substr(pid, 1,6) + substr(pid,9,4)
drop pid
ren p pid_link
gen Ronda = 2
save "$cd_data/Longitudinal/2009/2009_Final.dta", replace






*** 2005: households

use "$cd_data/Longitudinal/2005/Hogares/c_portad.dta", clear

merge 1:1 folio using "$cd_data/Longitudinal/2005/Hogares/c_cv.dta",
drop _m

merge 1:1 folio using "$cd_data/Longitudinal/2005/Hogares/c_cvo.dta",
drop _m

merge 1:1 folio using "$cd_data/Longitudinal/2005/Hogares/c_ne.dta",
drop _m

merge 1:1 folio using "$cd_data/Longitudinal/2005/Hogares/c_rc.dta",
drop _m

merge 1:m folio using "$cd_data/Longitudinal/2005/Hogares/Fechas.dta",
drop _m

*2005: individuals

merge 1:m folio using "$cd_data/Longitudinal/2005/Individuos/iiia_ee.dta",
keep if _m ==3
drop _m

merge 1:1 pid_link using "$cd_data/Longitudinal/2005/Individuos/iiia_ah.dta",
keep if _m ==3
drop _m

merge 1:1 pid_link using "$cd_data/Longitudinal/2005/Individuos/iiia_ed.dta",
keep if _m ==3
drop _m

merge 1:1 pid_link using "$cd_data/Longitudinal/2005/Individuos/iiia_iin.dta",
keep if _m ==3
drop _m

merge 1:1 pid_link using "$cd_data/Longitudinal/2005/Individuos/iiia_tb.dta",
keep if _m ==3
drop _m

merge 1:1 pid_link using "$cd_data/Longitudinal/2005/Individuos/iiib_rg.dta",
keep if _m !=2
drop _m

merge 1:1 pid_link using "$cd_data/Longitudinal/2005/Individuos/iiib_co.dta",
keep if _m !=2
drop _m

merge 1:1 pid_link using "$cd_data/Longitudinal/2005/Individuos/iiia_ata.dta",
keep if _m ==3
drop _m

merge 1:1 pid_link using "$cd_data/Longitudinal/2005/Individuos/iiib_sm.dta",
drop _m


merge 1:1 pid_link using "$cd_data/Longitudinal/2005/Individuos/iiib_pr.dta",
drop _m

merge 1:1 pid_link using "$cd_data/Longitudinal/2005/Individuos/iiia_vli.dta",
drop _m


merge 1:1 pid_link using "$cd_data/Longitudinal/2005/Individuos/iiia_shi.dta",
drop _m

gen Ronda = 1
save "$cd_data/Longitudinal/2005/2005_Final.dta", replace

tostring mpio, gen(mpioS)
tostring ent, gen (entS)
replace entS = "0"+entS if ent <10
replace mpioS = "00" + mpioS if mpio<10
replace mpioS = "0" + mpioS if mpio>=10 & mpio <100
gen clave_mun = entS+mpioS

append using "$cd_data/Longitudinal/2009/2009_Final.dta", force
gen year = anio + 2000
gen year_Original = year
*replace year  = year - 1 if mes <=3 & year >=2007

save "$cd_data/Longitudinal/20052009_Final_NoPanel.dta", replace


** squared database for longitudinal survey
*cd "/Users/Nico/Dropbox/Cheating in Mexico/"
*cd "C:\Users\Lenovo\Dropbox\Cheating in Mexico\"

** keep muns that are present in the survey
use "$cd_data/Longitudinal/20052009_Final_NoPanel.dta", clear
keep clave_mun
duplicates drop 
save "$cd_data/Longitudinal/Claves.dta", replace

** merge with corruption data just to get the mun id's that appear in the survey (will use them later)
use "$cd_data/Data_Corruption/TotalAuditoriasConMunicipio.dta", clear

keep clave_mun
duplicates drop
merge 1:1 clave_mun using "$cd_data/Longitudinal/Claves.dta"
keep if _merge ==3

drop _merge

save "$cd_data/Longitudinal/Claves.dta", replace
** Delete obs that are not in the survey (but yes in the corruption dataset)
** merge with corruption again
merge 1:m clave_mun using  "$cd_data/Data_Corruption/TodosLosMuni_ConAudits_ConAlreadyAudited.dta"
keep if _merge !=2

** keep from the corruption data the relevant variables (unauthorized expenditures, leads lags, corrupt past dummy, etc)
keep clave_mun year unautho Auditada Veces Corr_Acum Corrupt* una* CorruptPast*  C_menos1 C_menos2  C_1 C_2 lag* lead_*
sort clave_mun Aud year 
bysort clave_mun  Aud : gen nro_auditoria = _n if Aud == 1
replace Auditada = 0 if Auditada ==.
replace nro = 0 if nro ==.
replace unau = 0 if unau ==.
gen AlreadyAudited = 0
sort clave_mun year
* was already audited?
bysort clave_mun: replace Already = max(Auditada, Already[_n-1])

drop Veces
gen VecesAuditada = nro_auditoria
bysort clave_mun: replace Veces= Veces[_n-1] if Auditada ==0
replace Veces = 0 if Veces ==.

save "$cd_data/Longitudinal/Long_Cuadrada_NoPanel.dta", replace

use "$cd_data/Longitudinal/20052009_Final_NoPanel.dta", clear
merge m:1 clave_mun using "$cd_data/Longitudinal/Claves.dta"
keep if _merge !=2
drop _merge
save "$cd_data/Longitudinal/20052009_Final_NoPanel_Claves_Comunes.dta", replace

use "$cd_data/Longitudinal/Long_Cuadrada_NoPanel.dta", clear
merge 1:m clave_mun year using "$cd_data/Longitudinal/20052009_Final_NoPanel_Claves_Comunes.dta"
keep if _merge !=2
drop _merge


** merge with all the relevant controls

** political controls when corruption happened
merge m:m clave_mun year using "$cd_data/Base Presidentes/Muni_Presidentes_Desfasado.dta", gen(tt)
keep if tt ==3
drop tt


** political controls when corruption was discovered

merge m:m clave_mun year using "$cd_data/Base Presidentes/Muni_Presidentes.dta", gen(tt) force

keep if inlist(year, 2005,2006,2007,2009,2010, 2011, 2012, 2013)
keep if tt==3
drop tt
gen Igual = 0
replace Igual = 1 if Partido == PartidoDesf


** state controls

gen codigo_estado = substr(clave_mun,1,2)
destring codigo_estado, replace

** homicides, gdp (state)
merge m:m codigo_estado year using "$cd_data/Censo/Homicides_State.dta", gen(m_aux2)
merge m:m codigo_estado year using "$cd_data/Censo/GDP_State.dta", gen(m_aux)

keep if inlist(year, 2005,2006,2007,2009,2010, 2011, 2012, 2013)

** election at the mun level dummy

merge m:1 clave_mun year using "$cd_data/Base Presidentes/mun_elec.dta", gen(xxxx) force

** homicides per capita (municipality)
merge m:1 clave_mun year using "$cd_data/Censo/Homicides_2005_2013_Poblacion.dta", gen(merg)

keep if merg ==3
drop merg

replace Partido = "NS" if Partido == ""
replace PartidoDesf = "NS" if PartidoDesf == ""


** define corruption

cap drop Corrupt

gen Corrupt = 0
replace Corrupt =1 if unau >0 

** Make "Folio" number homogeneous across waves
gen PrimerasSeis = substr(folio,1,6)
gen SegundasDos =substr(folio,7,2)
gen TercerasDos = substr(folio,9,2)
gen TerceraUna = substr(folio,9,1)
gen FolioNuevo = folio if TercerasDos ==""
replace FolioNuevo = PrimerasSeis+Terceras if FolioNuevo ==""


gen mes2 = mes
gen anio2 = year
tostring anio2, replace
tostring mes2, replace
gen aniomes = anio2+mes2
ta aniomes, gen(aniomes_)
ta mes2, gen(mes_)
ta year, gen(yy)

cap drop _merge
keep if Folio!=""
qui ta clave_mun, gen(muni_)


ta nro, gen(NRO_)
cap drop yy_*
cap drop mes_*
ta mes, gen(mes_)
ta year, gen(yy_)

** This dataset contains the parties that were governing the municipalities, BUT now collapsed at the 3-main-national-parties-level (eg: party alliance, instead of local parties). Need this to create the dummy: local gov= national gov

merge m:1 year clave_mun using  "$cd_data/Base Presidentes/Partidos_Alianzas.dta", gen(merge_PD)
keep if year<2014 & year >2004
keep if merge_PD !=2
ren winner winner_D
merge m:1 year clave_mun using  "$cd_data/Base Presidentes/Partidos_Alianzas_Hecho.dta", gen(merge_P)
keep if year<2014 & year >2004
keep if merge_P !=2

** TAX COLLECTION DATA

merge m:1 clave_mun year using  "$cd_data/Censo/Taxes_mun_2006_2013.dta", gen(m_taxes)
keep if m_taxes!=2
drop m_taxes


*** INTERACTIONS FOR CONTROL IN ANALYSIS OF HETEROGENEITY


qui sum total if total>0, meanonly
gen total_mean=total-`r(mean)'
replace total_mean = 0 if mis_tot==1


gen inter_total_mean_a=total_mean*Auditada


gen PartG = "PAN"
replace PartG= "PRI" if year>2012
gen MismoPartidoG = 0
replace MismoPartidoG = 1 if PartG == winner_D


replace MismoPartidoG = 1 if PartG == winner_D

drop mis_tot
gen mis_tot = total ==.
replace total = 0 if mis_tot ==1




gen year_desfasado = year

gen Change = 0


* exclude month in which audit was released (month changed in 2009)
gen exclusion =0
replace exclusion  = 1 if year>2008 & mes ==2
replace exclusion = 1 if year <=2008& mes ==3

gen FirstMonths = 0
replace First = 1 if year ==2008 & inlist(mes,1,2)
replace First = 1 if year ==2009 & inlist(mes,1,2,3)

* create 6 months windows starting the month the report was released, then adapt all the variables to fit this windows
* basically "re-center" each year 
replace Change = 1 if inlist(mes,9,10,11,12) & year >2008
replace Change = 1 if inlist(mes,10,11,12) & year <=2008


replace year_d = year_d+1 if Change ==1
replace Already = lag_Already if Change ==1
replace Auditada = lag_Auditada1 if Change ==1


replace Corrupt = C_menos1 if Change ==1
replace Corrupt_15 = Corrupt_15_menos1 if Change ==1
replace Corrupt_25 = Corrupt_25_menos1 if Change ==1
replace unau = una_menos1 if Change ==1
gen Corruptlog = ln(unau*100+1)


replace CorruptPast = lag_CorruptPast if Change ==1
replace CorruptPast_15 = lag_CorruptPast_15 if Change ==1
replace CorruptPast_25 = lag_CorruptPast_25 if Change ==1

** Time 1/0 depending when the audit was released (month changed in 2009)
gen Time = 1


replace Time = 0 if inlist(mes,9,10,11,12,1,2) & year>2008
replace Time = 0 if inlist(mes,10,11,12,1,2,3) & year<=2008



** Treatment * Time for different thresholds

gen inter = Time*Corrupt
gen inter15=Time*Corrupt_15
gen inter25=Time*Corrupt_25
gen interlog=Time*Corruptlog


gen ln_unau=ln(unau+1)
gen inter_ln=Time*ln_unau











****************



**** VAR DEFINITIONS
* break the rules

gen Romper = 0 if co01 !=. & co01 !=8
replace Romper =1 if inlist(co01,1,2)


* to get ahead in life need to cheat

gen Tranza = 0 if co03 !=. & co03 !=8
replace Tranza =1 if inlist(co03,1,2)


* trustworthy

** 
gen Confiable = 1 if co05 !=8 & co05!=.
replace Confiable =0 if inlist(co05,1,2)

**


gen Tramposo = 0 if Romper ==0 & Tranza ==0
replace Tramposo = 1 if Romper ==1 | Tranza ==1


gen Indice_Tramposo = 0 if Romper ==0 & Tranza ==0
replace Indice_Tramposo = 1 if (Romper ==1 & Tranza ==0) | (Tranza ==1 & Romper ==0)
replace Indice_Tramposo = 2 if (Romper ==1 & Tranza ==1)


** steal electricity

su rg09_11 if rg09_11 >0
return list
gen Media_Robar = r(mean)
egen p90 = pctile(rg09_11), p(90)


gen Robar = 0 if rg09_11 !=.
replace Robar = 1 if rg09_11 >Media_Robar 
replace Robar = . if rg09_11==.

** not return wallet (with the opposite sign to make it compatible with the rest)

gen complemento = 100-rg12_11 if rg12_11 !=.

su complemento if complemento >0
return list
gen Media_NotReturn = r(mean)
egen nrp90 = pctile(complemento), p(90)


gen NotReturn = 0 if complemento !=.
replace NotReturn = 1 if complemento >Media_NotReturn
replace NotReturn = . if complemento ==.

gen Tramposo2 = 0 if Robar ==0 & NotReturn ==0
replace Tramposo2 = 1 if Robar ==1 | NotReturn ==1

gen Indice_Tramposo2 = 0 if Robar==0 & NotReturn ==0
replace Indice_Tramposo2 = 1 if (Robar ==1 & NotReturn ==0) | (NotReturn ==1 & Robar ==0)
replace Indice_Tramposo2 = 2 if (Robar ==1 & NotReturn ==1)


gen TramposoTotal = 0 if Tramposo ==0 & Tramposo2 ==0
replace TramposoTotal = 1 if Tramposo ==1 | Tramposo2 ==1

** general index using the 5 vars
egen Count_Index=rowtotal(Indice_Tramposo Indice_Tramposo2 Confiable)
replace Count_Index = . if Indice_Tramposo ==. | Indice_Tramposo2 ==.| Confiable ==.


** at least one

gen Uno = 0 if Count_Index <1
replace Uno = 1 if Count_Index >=1
replace Uno = . if Count_Index ==.

** at least two

gen Dos = 0 if Count_Index <2
replace Dos = 1 if Count_Index >=2
replace Dos = . if Count_Index ==.


*** principal component analysis

pca Romper NotReturn Robar Tranza Confiable
predict pc_1
egen A = min(pc_1)
egen B=max(pc_1)
gen Dif=B-A
gen index=(pc_1-A)/Dif
ren index Tres


**PLACEBOS


** Risk-Economy: "Likelihood of investing in a Tanda?"

su rg08_11 if rg08_11 >0
return list
gen Media_Tanda = r(mean)


gen Tanda = 0 if rg08_11 !=.
replace Tanda = 1 if rg08_11 >Media_Tanda
** Health-Risk: "Likelihood of eating greasy food?"

su rg10_11 if rg10_11 >0
return list
gen Media_Grasa = r(mean)


gen Grasa = 0 if rg10_11 !=.
replace Grasa = 1 if rg10_11 >Media_Grasa

** Preferences: "Likelihood of moving far from your family?"

su rg11_11 if rg11_11 >0
return list
gen Media_Mudarse = r(mean)


gen Mudarse = 0 if rg11_11 !=.
replace Mudarse = 1 if rg11_11 >Media_Mudarse


** Economy: "Likelihood of having enought money in three years?"

su rg15_11 if rg15_11 >0
return list
gen Media_Dinero_Suficiente = r(mean)


gen Dinero_Suficiente = 0 if rg15_11 !=.
replace Dinero_Suficiente = 1 if rg15_11 >Media_Dinero_Suficiente


su rg14_11 if rg14_11 >0
return list
gen Media_Dinero_Suficiente_HOY = r(mean)


gen Dinero_Suficiente_HOY = 0 if rg15_11 !=.
replace Dinero_Suficiente_HOY = 1 if rg15_11 >Media_Dinero_Suficiente_HOY


** Freedom: it's ok to do what you want as long as you don't hurt anyone


gen HacerSinMolestar = 0 if co02 !=.

replace HacerSinMolestar = 1 if inlist(co02,1,2)

** Saving/Consumption decisions?

** Discount rate?: if a rich familiar gives you 1000, how much would you spent in the next 30 days?

gen Gasto =  0 if co06 !=.
replace Gasto = co07_21 if co07_21 !=.


ta pr01, gen(think_)
gen PiensaFuturo = think_1

** Victimization

gen MiedoDia = 0 if vli01 !=.
replace MiedoDia = 1 if inlist(vli01,1,2)

gen MiedoNoche = 0 if vli02 !=.
replace MiedoNoche = 1 if inlist(vli02,1,2)

** being involved in fights

gen MetersePeleas = 0 if co04 !=.
replace MetersePeleas = 1 if inlist(co04,1,2)








****************


gen inter_audit = Time*Auditada


** individual controls
* labor status

replace tb02_1 = 10 if tb02_1 ==.
ta tb02_1, gen (TRABAJO_)
gen Ocupado = 0 if tb02_1 !=.
replace Ocupado = 1 if tb02_1 ==1

* education
replace ed06 = -1 if ed06 ==.

ta ed06, gen(nivelultimo_)
gen indigena = 0 if ed03 !=.
replace indigena = 1 if ed03==1
gen mis_ind = indigena ==.
replace indigena = 0 if indigena ==.

* age

ta edad, gen(ed_)
gen misedad=0
replace misedad=1 if edad==.
replace edad=0 if misedad==1

* party 

ta Partido, gen(P_)
ta PartidoD, gen(PDE_)

drop yy_*
ta year_d, gen(yy_)
tostring year_d, gen(y_)
gen y_y=clave_mun+y_

drop if edad==0


keep if exclusion == 0
keep if Auditada ==1




*********************** PART II: RUN REGRESSIONS ***********************

cap log close
log using "Tables/Table4.txt", text replace
*** TABLE IV

areg Count_Index inter Time Corrupt  , a(clave_mun) cluster(clave_mun)
areg Count_Index inter Time Corrupt P_* PDE_* , a(clave_mun) cluster(clave_mun)
areg Count_Index inter P_* PDE_* Time HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already, a(clave_mun) cluster(clave_mun)
areg Count_Index inter P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already TRABAJO_* ed_* , a(clave_mun) cluster(clave_mun)
areg Count_Index inter P_* PDE_*  yy_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already TRABAJO_* ed_* , a(clave_mun) cluster(clave_mun)


areg Uno inter Time Corrupt , a(clave_mun) cluster(clave_mun)
areg Uno inter Time Corrupt P_* PDE_*, a(clave_mun) cluster(clave_mun)
areg Uno inter P_* PDE_* Time HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already, a(clave_mun) cluster(clave_mun)
areg Uno inter P_* PDE_* Time  HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already yy_* , a(clave_mun) cluster(clave_mun)
areg Uno inter P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)

areg Dos inter Time Corrupt , a(clave_mun) cluster(clave_mun)
areg Dos inter Time Corrupt P_* PDE_*, a(clave_mun) cluster(clave_mun)
areg Dos inter P_* PDE_* Time HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already, a(clave_mun) cluster(clave_mun)
areg Dos inter P_* PDE_* Time  HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already yy_* , a(clave_mun) cluster(clave_mun)
areg Dos inter P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)


areg Tres inter Time Corrupt , a(clave_mun) cluster(clave_mun)
areg Tres inter Time Corrupt P_* PDE_*, a(clave_mun) cluster(clave_mun)
areg Tres inter P_* PDE_* Time HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already, a(clave_mun) cluster(clave_mun)
areg Tres inter P_* PDE_* Time  HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already yy_* , a(clave_mun) cluster(clave_mun)
areg Tres inter P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)

cap log close

cap log close
log using "Tables/Table5.txt", text replace

*** TABLE V


areg Tranza inter Time Corrupt , a(clave_mun) cluster(clave_mun)
areg Tranza inter Time Corrupt P_* PDE_*, a(clave_mun) cluster(clave_mun)
areg Tranza inter P_* PDE_* Time HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already, a(clave_mun) cluster(clave_mun)
areg Tranza inter P_* PDE_* Time  HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already yy_* , a(clave_mun) cluster(clave_mun)
areg Tranza inter P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)


areg Confiable inter Time Corrupt , a(clave_mun) cluster(clave_mun)
areg Confiable inter Time Corrupt P_* PDE_*, a(clave_mun) cluster(clave_mun)
areg Confiable inter P_* PDE_* Time HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already, a(clave_mun) cluster(clave_mun)
areg Confiable inter P_* PDE_* Time  HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already yy_* , a(clave_mun) cluster(clave_mun)
areg Confiable inter P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)


areg Romper inter Time Corrupt , a(clave_mun) cluster(clave_mun)
areg Romper inter Time Corrupt P_* PDE_*, a(clave_mun) cluster(clave_mun)
areg Romper inter P_* PDE_* Time HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already, a(clave_mun) cluster(clave_mun)
areg Romper inter P_* PDE_* Time  HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already yy_* , a(clave_mun) cluster(clave_mun)
areg Romper inter P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)


areg Robar inter Time Corrupt , a(clave_mun) cluster(clave_mun)
areg Robar inter Time Corrupt P_* PDE_*, a(clave_mun) cluster(clave_mun)
areg Robar inter P_* PDE_* Time HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already, a(clave_mun) cluster(clave_mun)
areg Robar inter P_* PDE_* Time  HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already yy_* , a(clave_mun) cluster(clave_mun)
areg Robar inter P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)


areg NotReturn inter Time Corrupt , a(clave_mun) cluster(clave_mun)
areg NotReturn inter Time Corrupt P_* PDE_*, a(clave_mun) cluster(clave_mun)
areg NotReturn inter P_* PDE_* Time HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already, a(clave_mun) cluster(clave_mun)
areg NotReturn inter P_* PDE_* Time  HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already yy_* , a(clave_mun) cluster(clave_mun)
areg NotReturn inter P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)

cap log close

cap log close
log using "Tables/TableA5.txt", text replace

** TABLE A5

areg Count_Index inter P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)
areg Count_Index inter15 P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast_15 Corrupt_15 Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)
areg Count_Index inter25 P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast_25 Corrupt_25 Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)
areg Count_Index interlog P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corruptlog Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)

areg Uno inter P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)
areg Uno inter15 P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast_15 Corrupt_15 Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)
areg Uno inter25 P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast_25 Corrupt_25 Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)
areg Uno interlog P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corruptlog Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)


areg Dos inter P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)
areg Dos inter15 P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast_15 Corrupt_15 Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)
areg Dos inter25 P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast_25 Corrupt_25 Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)
areg Dos interlog P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corruptlog Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)


areg Tres inter P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)
areg Tres inter15 P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast_15 Corrupt_15 Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)
areg Tres inter25 P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast_25 Corrupt_25 Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)
areg Tres interlog P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corruptlog Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)


cap log close

cap log close
log using "Tables/TableA6.txt", text replace

** TABLE A6

areg PiensaFuturo inter P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)
areg PiensaFuturo inter15 P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast_15 Corrupt_15 Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)
areg PiensaFuturo inter25 P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast_25 Corrupt_25 Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)
areg PiensaFuturo interlog P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corruptlog Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)

areg Gasto inter P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)
areg Gasto inter15 P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast_15 Corrupt_15 Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)
areg Gasto inter25 P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast_25 Corrupt_25 Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)
areg Gasto interlog P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corruptlog Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)

areg MiedoDia inter P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)
areg MiedoDia inter15 P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast_15 Corrupt_15 Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)
areg MiedoDia inter25 P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast_25 Corrupt_25 Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)
areg MiedoDia interlog P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corruptlog Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)

areg MiedoNoche inter P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)
areg MiedoNoche inter15 P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast_15 Corrupt_15 Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)
areg MiedoNoche inter25 P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast_25 Corrupt_25 Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)
areg MiedoNoche interlog P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corruptlog Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)

areg Dinero_Suficiente inter P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)
areg Dinero_Suficiente inter15 P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast_15 Corrupt_15 Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)
areg Dinero_Suficiente inter25 P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast_25 Corrupt_25 Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)
areg Dinero_Suficiente interlog P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corruptlog Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)

areg MetersePelea inter P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)
areg MetersePelea inter15 P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast_15 Corrupt_15 Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)
areg MetersePelea inter25 P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast_25 Corrupt_25 Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)
areg MetersePelea interlog P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corruptlog Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)

su  Tanda PiensaFuturo Gasto MiedoDia MiedoNoche Dinero_Suficiente Meterse



areg Tanda inter P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corrupt Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)
areg Tanda inter15 P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast_15 Corrupt_15 Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)
areg Tanda inter25 P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast_25 Corrupt_25 Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)
areg Tanda interlog P_* PDE_* Time nivelultimo_* HOMI_CAP_MUN total mis_tot MismoPartido CorruptPast Corruptlog Already TRABAJO_* ed_* yy_* , a(clave_mun) cluster(clave_mun)

cap log close


*** DESCRIPTIVE STATISTICS: TABLE A3
log using "Tables/TableA3.txt", text replace

su Count_Index Uno Dos Tres Tranza Confiable Romper Robar NotReturn

cap log close


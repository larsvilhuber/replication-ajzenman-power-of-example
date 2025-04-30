


cap log close
log using "Tables/TableA1.txt", text replace


** TABLE A1
use "$cd_data/BasesAnalisis/FinalDataBase_SecundariaBaseCompleta.dta", clear




replace prop = prop*100

table Grado if inrange(year, 2006, 2013), by(year) format(%9.1f) c(freq mean prop sd prop)

table Grado if inrange(year, 2006, 2013), by(year) format(%9.1f) c(min prop p99 prop max prop)



cap log close

cap log close
log using "Tables/TableA2.txt", text replace

** TABLE A2

use "$cd_data/Data_Corruption/TotalAuditoriasConMunicipio.dta", clear

gen Corrupt = unau>0

* bys year: su unau Corrupt if inrange(year, 2006, 2013)

table year if inrange(year, 2006, 2013), format(%9.2f) c(n Auditada mean unau sd unau min unau max unau)
table year if inrange(year, 2006, 2013), format(%9.2f) c(n Auditada mean Corrupt)

cap log close

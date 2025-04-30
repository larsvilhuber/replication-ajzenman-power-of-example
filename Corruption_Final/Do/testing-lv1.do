include "config.do"
global cdname "$rootdir"

global cd_do "$cdname/Do"
global cd_data "$cdname/Data"

use "$cd_data/Longitudinal/Claves.dta", clear
** Delete obs that are not in the survey (but yes in the corruption dataset)
** merge with corruption again
merge 1:m clave_mun using  "$cd_data/Data_Corruption/TodosLosMuni_ConAudits_ConAlreadyAudited.dta"
keep if _merge !=2
desc
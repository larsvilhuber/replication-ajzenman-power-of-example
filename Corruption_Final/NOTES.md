# Notes on replication of Ajzenman

## System

- OS: "openSUSE Leap 15.6"
- Processor:  AMD Ryzen 9 3900X 12-Core Processor, 24 cores
- Memory available: 125GB memory
- Docker version 27.5.1-ce, build 4c9b3b011ae4 
- stata version 18-mp-i (Docker image dataeditors/stata18-mp-i:2024-12-18)


## Bugs

- Variable name: `ren ïentidad ent` was recoded as `ren entidad ent` (https://github.com/larsvilhuber/replication-ajzenman-power-of-example/commit/95ea3eee0cec1ffd50ac6bf78180b66c849703a0)
- Filename: one of 13 database files (`Data/Bases Madre/Homicides/DEFUN13.DBF`) has a different case, on a case-sensitive file system. All others are lower-case `dbf`. Manually modified the filename to be lower-case. (https://github.com/larsvilhuber/replication-ajzenman-power-of-example/blob/main/Corruption_Final/logs/logfile_30_Apr_2025-13_37_20-statauser.log#L811)
- Bug related to Stata version: `option contents() not allowed since Stata 17; see help table for updated syntax`

## Structure

There are 143 `areg` regressions. The tables are not cleanly output.

Runtime: 1 hour 9 minutes (until bug)

## Table 4:

To identify all coefficients from the separate regressions, I used `grep` to parse the Stata log file captured for `Table4.txt`:

```bash
grep -n "inter" Table4.txt | grep -v areg | awk ' { print $1, $2, $4, $5 } ' 
```

The output is:

```
24: inter .2588744 .0955364
84: inter .4995433 .1963678
215: inter .5450504 .1686364
358: inter .5299935 .1729945
610: inter .6067147 .1414045
825: inter .1218765 .0556162
885: inter .1802902 .0995852
1016: inter .1839404 .0886252
1154: inter .1975147 .0725312
1309: inter .1856933 .0706579
1523: inter .1106731 .0370288
1583: inter .2172922 .0713383
1714: inter .2479733 .0547653
1852: inter .2607372 .045871
2007: inter .2590473 .0523933
2222: inter .0756975 .0211231
2282: inter .1179639 .0411609
2413: inter .1242549 .0370961
2551: inter .1416991 .027053
2706: inter .1398497 .0295395
```

Reverse engineering variable names:

- `Uno` = "at least 1 incivic value"
- `Dos` = "at least 2 incivic values"
- `Tres` = "1st component PCA with 4 incivic values"
- `Count_Index` = "Count index (sum 5 incivic values)"

## Checked variable definitions

- `Count_Index`:

```
** general index using the 5 vars
egen Count_Index=rowtotal(Indice_Tramposo Indice_Tramposo2 Confiable)
replace Count_Index = . if Indice_Tramposo ==. | Indice_Tramposo2 ==.| Confiable ==.
```

- `Uno`:

```
Values.do:503:gen Uno = 0 if Count_Index <1
Values.do:504:replace Uno = 1 if Count_Index >=1
Values.do:505:replace Uno = . if Count_Index ==.
```

- `Dos`:

```
Values.do:509:gen Dos = 0 if Count_Index <2
Values.do:510:replace Dos = 1 if Count_Index >=2
Values.do:511:replace Dos = . if Count_Index ==.
```

- `Tres`:

```
pca Romper NotReturn Robar Tranza Confiable
predict pc_1
egen A = min(pc_1)
egen B=max(pc_1)
gen Dif=B-A
gen index=(pc_1-A)/Dif
ren index Tres
```

> The variable of interest is CorruptAfter(mtf)​ and is the interaction between ​​Corrupt(​mt)​​​ (a dummy that scores 1 if the municipality m is corrupt during a
particular period t) and ​​After(f) (a dummy that takes on a value of 1 if the interview of the individual was performed before the month of February, when the reports
were released, and 0 otherwise).

```
keep clave_mun year unautho Auditada Veces Corr_Acum Corrupt* una* CorruptPast*  C_menos1 C_menos2  C_1 C_2 lag* lead_*
sort clave_mun Aud year 
bysort clave_mun  Aud : gen nro_auditoria = _n if Aud == 1
replace Auditada = 0 if Auditada ==.
replace nro = 0 if nro ==.
replace unau = 0 if unau ==.
...
gen Corrupt = 0
replace Corrupt =1 if unau >0 
```

Test code:

```
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
```

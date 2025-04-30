# Notes on replication of Ajzenman

## System 1 

- OS: "openSUSE Leap 15.6"
- Processor:  AMD Ryzen 9 3900X 12-Core Processor, 24 cores
- Memory available: 125GB memory
- Docker version 27.5.1-ce, build 4c9b3b011ae4 
- stata version 18-mp-i (Docker image dataeditors/stata18-mp-i:2024-12-18)

## System 2

## System 3



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
          Coefficient  std.err. t   P>|t|     
25: inter .2588744 .0955364 2.71 0.008
87: inter .4995433 .1963678 2.54 0.013
219: inter .5450504 .1686364 3.23 0.002
364: inter .5299935 .1729945 3.06 0.003
618: inter .6067147 .1414045 4.29 0.000  <== Column 5
834: inter .1218765 .0556162 2.19 0.031
895: inter .1802902 .0995852 1.81 0.074
1027: inter .1839404 .0886252 2.08 0.041
1166: inter .1975147 .0725312 2.72 0.008
1323: inter .1856933 .0706579 2.63 0.010  <== Column 5
1538: inter .1106731 .0370288 2.99 0.004
1599: inter .2172922 .0713383 3.05 0.003
1731: inter .2479733 .0547653 4.53 0.000
1870: inter .2607372 .045871 5.68 0.000
2027: inter .2590473 .0523933 4.94 0.000  <== Column 5
2243: inter .0756975 .0211231 3.58 0.001
2304: inter .1179639 .0411609 2.87 0.005
2436: inter .1242549 .0370961 3.35 0.001
2575: inter .1416991 .027053 5.24 0.000
2732: inter .1398497 .0295395 4.73 0.000  <== Column 5
```

Reverse engineering variable names:

- `Uno` = "at least 1 incivic value"
- `Dos` = "at least 2 incivic values"
- `Tres` = "1st component PCA with 4 incivic values"
- `Count_Index` = "Count index (sum 5 incivic values)"

## Robustness check 1

### Checked variable definitions

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
drop Corrupt
gen Corrupt = 0
replace Corrupt =1 if unau >0
tab Corrupt
```

Results

```
. tab Corrupt

    Corrupt |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |      1,370       85.31       85.31
          1 |        236       14.69      100.00
------------+-----------------------------------
      Total |      1,606      100.00
```


> Definitions: “Count
index”: sum of five incivic answers; “At least 1”: at least one incivic answer; “At least 2”: at least two incivic
answers; “PC”: First component of a PCA (normalized to a 0–1 scale). The exact wording of the individual ques-
tions is as follows: (i) “The one who does not cheat, does not get ahead” (Completely Agree, Agree, Disagree,
Completely Disagree); (ii) “Are you trustworthy?” (Completely Agree, Agree, Disagree, Completely Disagree);
(iii) “Laws were made to be broken” (Completely Agree, Agree, Disagree, Completely Disagree); (iv) “How likely
is it that you steal electricity from the public lines (illegally)”? (1 to 100); (v) “How likely is it that you return a
wallet with 500 pesos in it?” (1 to 100). In brackets: the estimated coefficients divided by the standard deviation
of each variable.

### Coding

`Romper` is coded `1` if respondent agrees or completely agrees. Median = `Completely disagree`. 

Trustworthiness `Confiable` is reverse coded: it is set to 1 if the respondent disagrees or completely disagrees. Median = `Agree`.

Steal electricity is coded `1` if the respondents answer is above the mean. Mean = `6.58%`.

Return wallet is coded `1` if the respondents answer is above the mean. Mean = `64.20%`. Self-reported approx. probablity: `81.30%`

```
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
```

Changes these to be more extremely "poor judgement": limited to `completely agree` (or reverse coded `completely disagree`), and to the 90 percentiles.

Results:

```
          Coefficient  std.err. t   P>|t| 
25: inter -.0285057 .1090595 -0.26 0.795
87: inter .0817852 .1547545 0.53 0.599
219: inter .0600518 .1328355 0.45 0.653
364: inter -.0051433 .1228959 -0.04 0.967
618: inter .0994415 .1170965 0.85 0.398     <== Column 5
834: inter -.0390027 .0753067 -0.52 0.606
895: inter .0107975 .1158709 0.09 0.926
1027: inter -.0100146 .1081729 -0.09 0.926
1166: inter .0306619 .1096336 0.28 0.780
1323: inter -.0048173 .1015055 -0.05 0.962  <== Column 5
1538: inter .0059874 .0325353 0.18 0.854
1599: inter .0412236 .0484137 0.85 0.397
1731: inter .0416201 .0429528 0.97 0.336
1870: inter .0695075 .0332821 2.09 0.040
2027: inter .0520482 .0291082 1.79 0.078  <== Column 5
2243: inter .0414757 .0115817 3.58 0.001
2304: inter .0687284 .0193136 3.56 0.001
2436: inter .0613907 .0178548 3.44 0.001
2575: inter .0658179 .0188798 3.49 0.001
2732: inter .0599955 .0213624 2.81 0.006  <== Column 5
```


Strongly reduces magnitude (by about half), and significance of many of the coefficients (mostly the PCA remains significant, none of the others at conventional levels).


> - Program: [Corruption_Final/Do/Values_robustness.do](Corruption_Final/Do/Values_robustness.do)
> - Output: [Corruption_Final/Do/Values_robustness.log](Corruption_Final/Do/Values_robustness.log) and [Corruption_Final/Tables/Table4-robustness1.txt](Corruption_Final/Tables/Table4-robustness1.txt)

## Robustness check 2

> - Program: [Corruption_Final/Do/robustness_GAB_1&2.do](Corruption_Final/Do/robustness_GAB_1&2.do)

## Robustness check 3

> - Program: [Corruption_Final/Do/Robust_3_LPM.do](Corruption_Final/Do/Robust_3_LPM.do)


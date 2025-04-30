
*** THE POWER OF EXAMPLE: CORRUPTION SPURS CORRUPTION (BY NICOLAS AJZENMAN)
*** PROJECT ID: openicpsr-118971

clear all
set more off
set maxvar 32767
set matsize 11000
* Checking:

* Change globals!

*global cdname "C:\EESP\"
** TO RUN THE DO FILE YOU JUST NEED TO CHANGE THIS LINE.
global cdname /Users/nicolasajzenman/Dropbox

global cd_do "$cdname/Corruption_G/Do"
global cd_data "$cdname/Corruption_G/Data"

cd "$cdname/Corruption_G/"


** Create some of the controls
do "Do/Raw.do"
** Create the cheating db
do "Do/DB_Secondary.do"
** Create a balanced panel of corruption scandals
do "Do/GenerarBaseCuadradaDeMunicipiosTotal.do"
** Create the cheating dataset (secondary schools), merge it with corruption and run regessions
do "Do/MergeAnalysisBaseCompleta2.do"
** Create the cheating dataset (primary schools), merge it with corruption and run regessions
do "Do/MergeAnalysisPrimarias.do"
** Create the values dataset merge it with corruption and run regessions + descriptive stats (values)
do "Do/Values.do"
** Descriptive stats (except values)
do "Do/Descriptivas.do"


*** Mapping of tables and figures:

* Figure 1: not produced in the code (it's an illustrative timeline with no real data)
* Figure 2: not produced in the code (it comes directly from Google Searches)
* Figure 3: MergeAnalysisBaseCompleta2.do (line 432)
* Figure 4: MergeAnalysisBaseCompleta2.do (line 544)
* Figure 5: not produced in the code (it's a map based on public data that can be downloaded from here https://www.ine.mx/actores-politicos/administracion-tiempos-estado/catalogo-medios-aprobados/)
* Figure 6: MergeAnalysisBaseCompleta2.do (line 987)

* Table 1 : MergeAnalysisBaseCompleta2.do (line 487)
* Table 2 : MergeAnalysisBaseCompleta2.do (line 500)
* Table 3 : MergeAnalysisPrimarias.do (line 177)
* Table 4 : Values.do (line 670)
* Table 5 : Values.do (line 703)
* Table 6 : MergeAnalysisBaseCompleta2.do (line 925)
* Table 7 : MergeAnalysisBaseCompleta2.do (line 955)

* Figure A1: MergeAnalysisBaseCompleta2.do (line 417)
* Figure A2: MergeAnalysisBaseCompleta2.do (line 24)
* Figure A3: MergeAnalysisBaseCompleta2.do (line 586)
* Figure A4: MergeAnalysisBaseCompleta2.do (line 754)

* Table A1 : Descriprtivas.do (line 14)
* Table A2 : Descriprtivas.do (line 14)
* Table A3 : Values.do (line 821)
* Table A4 : not produced in the code (it was taken directly from the report that can be found in this websites: 

*https://gabinete.mx/images/estudios/2007/encueta_nacional_2007.pdf

*https://docplayer.es/45997522-Encuesta-nacional-gobierno-sociedad-y-politica.html (same information, better resolution)


* Table A5 : Values.do (line 745)
* Table A6 : Values.do (line 775)



* DATA SOURCES:


/*

- Cheating Data: Secretaria de Educacion Publica de Mexico (SEP). All the files by year can be downloaded from this website:

https://www.inee.edu.mx/bases-de-datos-inee-2019#planea (Search "ENLACE"). Files are in csv format, by school and year (primary and secondary) for the entire period the test was conducted (2006-2013).
In 2019, the files were moved from their original website (www.enlace.sep.gob.mx). 

In case a link is broken or a file is missing in the new website, the information must be requested through an open-data request (the data is public, it is not confidential, it does not require any agreement and is already produced), here:
http://www.infodf.org.mx/index.php/solicita-informacion-publica/%C2%BFc%C3%B3mo-puedo-solicitarla.html 
T
he requested data should include the following fields: (a) CVE_MUN (municipality code), (b) CVE_ENT (state code), (c) CCT (school code), (e) Turno (shift), (f) Cantidad de pruebas no confiables por grado (number of tests classified as "cheating" by grade), (g) Cantidad de alumnos evaluados por grado (number of tests per grade), 
and should be directed to the SEP (Secretaria de Educacion Publica). In the request, the level (Basica Primaria or Basica Secundaria: primary or secondary) must be stated.




- Corruption Data: Auditoria Superior de la Federacion

There is no single database. Data is provided in pdfs and must be manually transformed to DTA. All the original files, by year, can be accessed here:

https://www.asf.gob.mx/Section/58_Informes_de_auditoria

Click in "Informe del Resultado de la Fiscalización Superior de la Cuenta Pública X" (where X = year) to access each file.

Once there, click in "Gasto Federalizado" (for instance, for 2010: https://www.asf.gob.mx/Trans/Informes/IR2010i/Indice/Auditorias.htm)

Then, look for "RAMO GENERAL 33. FONDO PARA LA INFRAESTRUCTURA SOCIAL MUNICIPAL (FISM)" and click in each municipality to download the report in pdf.

For instance: https://www.asf.gob.mx/Trans/Informes/IR2010i/Grupos/Gasto_Federalizado/2010_0321.pdf (Aguascalientes, 2010). 




- Electoral Data-base (I): CIDAC


The full dataset can be downloaded here : http://cidac.org/base-de-datos-electoral/




- Electoral Data-base (II): INAFED Encyclopedia of Municipalities

The data can be downloaded from this link: http://www.snim.rami.gob.mx/

There, click on "Informacion Historica" and then "Presidentes Municipales". 

To build the database, it is necessary to search by municipality (one by one). First choosing state ("Entidad Federativa") and then municipality ("municipio"). 

It can be downloaded here: http://cidac.org/base-de-datos-electoral/




- Perceptions of Corruption: Gabinete de Comunicacion Estrategica


It can be downloadad (in pdf) from this link: https://gabinete.mx/images/estudios/2007/encueta_nacional_2007.pdf

Or this one: https://docplayer.es/45997522-Encuesta-nacional-gobierno-sociedad-y-politica.html (exactly the same information, better resolution)



- Values Data: Mexican Family Life Survey (MxFLS)

Wave 1) It can be downloaded from here http://www.ennvih-mxfls.org/english/ennhiv-2.html


File: http://www.ennvih-mxfls.org/english/assets/hh05dta_all.zip --> contains ALL the datasets used in this paper from wave 1


Wave 2) It can be downloadad from here http://www.ennvih-mxfls.org/english/ennhiv-3.html

File: http://www.ennvih-mxfls.org/english/assets/hh09dta_all.zip --> contains ALL the datasets used in this paper from wave 2






*/





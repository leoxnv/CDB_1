/*******************************************************************************
AUTHOR: Leonel Fernandez 
LAST VERSION DATE: Dec, 5th 2016
VERSION: 0.9 NOT FINAL VERSION. PLEASE DO NOT SHARE WITHOUT CONSENT
PURPOSE: Create clean database and indicators of official crime data in Mexico
DATA IN: 
			-IncidenciaDelictiva_FueroComun_Estatal_1997-{MONTH_YEAR}.xls 
			(Raw monthly data of 66 crime types in the 32 federative entities 
			of México, 1997-actual [Updates in the 20th of each month])
			
			-Incidencia Delictiva FC Municipal 2011 -©.xlsx"(Raw monthly 
			data of 66 crime types in all the municipalities 
			of México, 1997-actual [Updates in the 20th of each month])
			
			-state-population.csv (Cleaned estimated mid-year population data at 
			the state level from the CONAPO (2010) by Diego Valle
			https://github.com/diegovalle/conapo-2010
			
			-municipio-population2010-2030.csv (Cleaned estimated mid-year 
			population data at the municipal level from the CONAPO (2010)
			by Diego Valle.  https://github.com/diegovalle/conapo-2010
			
			-MaestroCodigosMunicipios.dta (Date base with INEGI and crime codes 
			for all municipalities in México and with their correpsondent
			ZM code. Author Leonel Fernández Novelo)
DATA OUT: 

			-state_rate.dta, state_total.dta
			-municip_rate.dta, municip_total.dta
			-zm_rate.dta, zm_total.dta
				
INSTRUCTIONS: This do-file works in three steps:
1. Generate macros, create folders and download databases (Stata process 
	Lines 60 to 121)
2. Opening Binary excel files (.xlsb) and export them to Excel Spreadsheet 
	format (.xlsx)
3. Cleaning data bases (lines 122 to 809)

First step: 
Define the working directory. Change the route in line 67. 
The program will create a directory called "Crime rates in Mexico" inside
the defined working directory.

Second step: 
Run the do-file, it will stop on line 101 after 'exit' command.

Third step: Go to the "Crime rates in Mexico" folder and open this two .xlsb files: 
~/Crime rates in Mexico/States/Files/IncidenciaDelictiva_FueroComun_Estatal_1997-2016.xlsb
 and
~/Crime rates in Mexico/Municipalities/Files/Incidencia Delictiva FC Municipal 2011 - 2016.xlsb
save them as .xlsx files DO NOT CHANGE THE NAME, JUST THE EXTENSION

Fourth step:
Run from line 122 to the end of the program.

Fifth step: 
Open do files 2, 3 and 4 to crate tables.
*******************************************************************************/

capture noisily version 13.1
clear all
set more off
capture log close


* Defining globals*
global folder "~/Dropbox" 	//<-Change working dir here  
global rates "$folder/Crime rates in Mexico"
global states "$rates/States"
global mun "$rates/Municipalities"
global zm "$rates/Metro Zones"
global prevst "$states/Files/Prev_Files"
global prevmp "$mun/Files/Prev_files"
local logdate = subinstr(trim("$S_DATE"), " ", "_", .)
local dbdate = subinstr(trim(substr("$S_DATE",3,.))," ","_",.)
global analysis "$rates/Analisis/"
global analisis "$rates/Analisis/$S_DATE"



*Creating working directories
cd "$folder"
capture noisily mkdir "Crime rates in Mexico"
cd "Crime rates in Mexico" 
capture noisily mkdir Logs
capture noisily mkdir States
capture noisily mkdir Municipalities
capture noisily mkdir "Metro Zones"
capture noisily mkdir "Analisis"
cd States
capture noisily mkdir Files
cd Files
capture noisily mkdir Prev_Files

cd ..
cd ..
cd Municipalities
capture noisily mkdir Files
cd Files
capture noisily mkdir Prev_Files
cd ..
cd ..
cd "Metro Zones"
capture noisily mkdir Files
cd ..
cd Analisis
capture noisily mkdir "$S_DATE"
cd "$S_DATE"
capture noisily mkdir States
capture noisily mkdir Municipalities


*Part 2*

set more off
/* Do file stops here. Number 4 not working. You will have to open the .xlsb file in Excel and save it as "Incidencia Delictiva FC Municipal 2011 - 2016.xlsx" in the same foder
and relaunch dofile since this point*/
cd "$states/Files"


/*2*/ global state_x "$states/Files/IncidenciaDelictiva_FueroComun_Estatal_1997-2016.xlsx"
		copy "$state_x" IncidenciaDelictivaEstatal.xlsx, replace
		


cd "$mun/Files"	

		
/*4*/ global mun_x "$mun/Files/Incidencia Delictiva FC Municipal 2011 - 2016.xlsx"
		copy "$mun_x" IncidenciaDelictivaMunicipal.xlsx, replace
		

set more off

****STATE LEVEL CRIME DATA IN MEXICO 1997-ACTUAL*******************************
cd "$states/Files"

*Preparing population data base*
clear
import delimited "$states/Files/statepop.csv"
drop if year > 2016 | year <1997
rename statecode state_code
drop females males 
save statepop.dta, replace


collapse (sum) total, by (year)
gen state_code = 0
gen statename = "NACIONAL"
save statepop_nac.dta, replace
append using statepop.dta
save statepop.dta, replace

*Cleaning SESNSP's crime data set*
clear
import excel using "IncidenciaDelictivaEstatal.xlsx", firstrow
drop if AÑO == .

**Erase leading, trailing and intermediate blank spaces in all string variables
replace  ENTIDAD = trim(itrim(ENTIDAD))
replace  MODALIDAD = trim(itrim(MODALIDAD))
replace  TIPO = trim(itrim(TIPO))
replace  SUBTIPO = trim(itrim(SUBTIPO))

*Encoding state codes*
rename INEGI state_code 

labmask state_code, val(ENTIDAD)

capture noisily drop ENTIDAD  
capture noisily drop TOTALAO

*Renaming variables*
rename (AÑO MODALIDAD TIPO SUBTIPO ENERO* FEBRERO* MARZO* ABRIL* MAYO* JUNIO* ///
	JULIO* AGOSTO* SEPTIEMBRE* OCTUBRE* NOVIEMBRE* DICIEMBRE*)(year category ///
	type subtype ene* feb* mar* abr* may* jun* jul* ago* sep* oct* nov* dic*)



*Encoding crime, category, type and subtype
encode category, gen(categoryid)
encode type, gen(typeid)
encode subtype, gen(subtypeid)
label define categoryid 11 "ROBO TOTAL", add
label define categoryid 0"INCIDENCIA DELICTIVA", add
label define typeid 19 "TOTAL",add
label define subtypeid 30 "TOTAL",add



order state*  year *id 

destring ene-dic, replace

save Iestatalmensual.dta, replace


***Totales con o sin violencia por suptipo de robo (Con o sin violencia (typeid))***

*Robo comun**

keep if categoryid == 7 | categoryid == 9 | categoryid == 10

collapse (sum)  ene-dic , by(state_code state  year categoryid subtypeid)
gen typeid:typeid = 19

order state*  year category type subtype

save robo.dta, replace 

************


use Iestatalmensual.dta, clear

***Totales por tipo***
*Total de despojo, homicidio doloso, homicidio culposo, lesiones dolosas, culposas y robo comun con y sin violencia, robo a casa habitaciom
** con y sin violencia, robo a isnt bancarias con y sin violencia**

keep if typeid == 8 | categoryid == 3 | categoryid == 4| categoryid == 7 | categoryid == 9 | categoryid == 10

collapse (sum)  ene-dic  , by(state_code state year categoryid typeid)
gen subtypeid:subtypeid = 30
order state*  year category type subtype

save types.dta, replace




******************
** totales por categoria***

use Iestatalmensual.dta, clear

drop if categoryid == 1 | categoryid == 2 |categoryid == 6 | categoryid == 8
collapse (sum)  ene-dic  , by(state_code state  year categoryid)

gen subtypeid:subtypeid = 30

gen typeid:typeid = 19

order state*  year category type subtype

save categorias.dta, replace

*** total robo **
use Iestatalmensual.dta, clear
keep if categoryid >6
collapse (sum)  ene-dic  , by(state_code state  year typeid)
gen dummy = 1 if typeid ==1 | typeid == 17
replace dummy = 2 if dummy == .
collapse (sum)  ene-dic  , by(state_code state  year dummy)
gen categoryid:categoryid = 11
gen typeid:typeid =4 if dummy == 2
replace typeid =17 if dummy ==1
gen subtypeid:subtypeid =30
drop dummy
save roboviolenciatotal.dta, replace
collapse (sum)  ene-dic  , by(state_code state  year categoryid subtypeid)
gen typeid:typeid =19
save robototal.dta, replace 


** total delitos**
use Iestatalmensual.dta, clear
collapse (sum)  ene-dic  , by(state_code state year)
gen categoryid:categoryid=0
gen typeid:typeid=19
gen subtypeid:subtypeid=30
save total.dta, replace

clear
append using "Iestatalmensual.dta" "robo.dta" "types.dta" "categorias.dta" "roboviolenciatotal.dta" "robototal.dta" "total.dta"

order state* year category type subtype
sort state_code year category type subtype 

save Iestatalmensual.dta, replace


collapse (sum) ene-dic, by (year categoryid typeid subtypeid )
gen state_code:state_code = 0
gen state = "NACIONAL"
append using "Iestatalmensual.dta"
order state* year category type subtype
sort state_code year category type subtype 


/*Creating crime variable wich groups all categories of "ROBO" in just one*

gen crime = category
replace crime = "ROBO" if word(category,1) == "ROBO"
encode crime, gen(crimeid)  
 CHECA!!!!!*/

drop  category type subtype

save Iestatalmensual.dta, replace


**tasas***
merge m:1 year state_code using statepop.dta
drop statename _merge state
rename total pop

foreach var of varlist ene-dic {
	gen t`var' = (`var' * 100000)/ pop
}

save Iestatalmensual.dta, replace
***



drop tene-tdic pop


reshape wide ene-dic, i(state_code  categoryid typeid subtypeid ) j(year)


forvalues i = 1997/2016 {
egen t1`i' = rowtotal (ene`i' feb`i' mar`i')
egen t2`i' = rowtotal (abr`i' may`i' jun`i')
egen t3`i' = rowtotal (jul`i' ago`i' sep`i')
egen t4`i' = rowtotal (oct`i' nov`i' dic`i')
}

forvalues i = 1997/2016 {
egen c1`i' = rowtotal (ene`i' feb`i' mar`i' abr`i')
egen c2`i' = rowtotal (may`i' jun`i' jul`i' ago`i')
egen c3`i' = rowtotal (sep`i' oct`i' nov`i' dic`i')
}

forvalues i = 1997/2016 {
egen s1`i' = rowtotal (ene`i' feb`i' mar`i' abr`i' may`i' jun`i')
egen s2`i' = rowtotal (jul`i' ago`i' sep`i' oct`i' nov`i' dic`i')
}

forvalues i = 1997/2016 {
egen a`i' = rowtotal (ene`i' feb`i' mar`i' abr`i' may`i' jun`i' jul`i' ago`i' sep`i' oct`i' nov`i' dic`i')
}

cd "$states"

save state_total.dta, replace



/*
export excel state_code - subtypeid a1997-a2016  using "$states/state_total.xlsx", sheet("anual") sheetmodify cell(A1) firstrow(varlabels)
export excel state_code - subtypeid ene1997-dic2016  using "$states/state_total.xlsx", sheet("mensual") sheetmodify cell(A1) firstrow(varlabels)
export excel state_code - subtypeid t11997-t42016  using "$states/state_total.xlsx", sheet("trimestral") sheetmodify cell(A1) firstrow(varlabels)
export excel state_code - subtypeid c11997-c32016 using "$states/state_total.xlsx", sheet("cuatrimestral") sheetmodify cell(A1) firstrow(varlabels)
export excel state_code - subtypeid s11997-s22016  using "$states/state_total.xlsx", sheet("semestral") sheetmodify cell(A1) firstrow(varlabels)
*/


use "Files/Iestatalmensual.dta", clear

drop ene-dic pop


reshape wide tene-tdic, i(state_code  categoryid typeid subtypeid ) j(year)


forvalues i = 1997/2016 {
egen t_t1`i' = rowtotal (tene`i' tfeb`i' tmar`i')
egen t_t2`i' = rowtotal (tabr`i' tmay`i' tjun`i')
egen t_t3`i' = rowtotal (tjul`i' tago`i' 	tsep`i')
egen t_t4`i' = rowtotal (toct`i' tnov`i' tdic`i')
}

forvalues i = 1997/2016 {
egen t_c1`i' = rowtotal (tene`i' tfeb`i' tmar`i' tabr`i')
egen t_c2`i' = rowtotal (tmay`i' tjun`i' tjul`i' tago`i')
egen t_c3`i' = rowtotal (tsep`i' toct`i' tnov`i' tdic`i')
}

forvalues i = 1997/2016 {
egen t_s1`i' = rowtotal (tene`i' tfeb`i' tmar`i' tabr`i' tmay`i' tjun`i')
egen t_s2`i' = rowtotal (tjul`i' tago`i' tsep`i' toct`i' tnov`i' tdic`i')
}

forvalues i = 1997/2016 {
egen t_a`i' = rowtotal (tene`i' tfeb`i' tmar`i' tabr`i' tmay`i' tjun`i' tjul`i' tago`i' tsep`i' toct`i' tnov`i' tdic`i')
}


save state_rate.dta, replace

use "Files/statepop.dta", clear
reshape wide total , i(state_code statename ) j(year)

labmask state_code, val(statename)

drop statename

save "Files/poblacionestados.dta", replace




cd Files

rm Iestatalmensual.dta
rm robo.dta
rm robototal.dta
rm roboviolenciatotal.dta
rm categorias.dta
rm total.dta
rm types.dta
rm statepop_nac.dta
rm incidencia_e.zip
rm "IncidenciaDelictiva_FueroComun_Estatal_1997-2016.xlsx"
rm "statepop.csv"
rm "IncidenciaDelictivaEstatal.xlsx"



*******+++++++++++++++++++++++++++++++Municipios*******
*Preparing population data base*
cd "$mun/Files"

clear
import delimited munpop.csv
drop if sex == "Males" | sex == "Females"
drop sex
drop if year > 2016 | year <2011
rename (population code) (pop mun_code)

save munpop.dta, replace



clear
set more off
cd "$mun/Files"
set excelxlsxlargefile on
import excel using "IncidenciaDelictivaMunicipal.xlsx", firstrow
set more off
drop if AÑO == .
save delitos-fuero-comun.dta, replace
use delitos-fuero-comun.dta, clear
**Erase leading, trailing and intermediate blank spaces in all string variables
replace  ENTIDAD = trim(itrim(ENTIDAD))
replace  MUNICIPIO = trim(itrim(MUNICIPIO))
replace  MODALIDAD = trim(itrim(MODALIDAD))
replace  TIPO = trim(itrim(TIPO))
replace  SUBTIPO = trim(itrim(SUBTIPO))

replace SUBTIPO ="CON ARMA DE FUEGO" if SUBTIPO == "POR ARMA DE FUEGO"
replace SUBTIPO ="CON ARMA BLANCA" if SUBTIPO == "POR ARMA BLANCA"


*Encoding codes*
encode ENTIDAD, gen(state_code) 
drop ENTIDAD 

*Renaming variables*
rename (INEGI MUNICIPIO AÑO MODALIDAD TIPO SUBTIPO ENERO* FEBRERO* MARZO* ABRIL* MAYO* JUNIO* ///
	JULIO* AGOSTO* SEPTIEMBRE* OCTUBRE* NOVIEMBRE* DICIEMBRE*)(mun_code municip year category ///
	type subtype ene* feb* mar* abr* may* jun* jul* ago* sep* oct* nov* dic*)



*Creating crime variable wich groups all categories of "ROBO" in just one*
*gen crime = category
*replace crime = "ROBO" if word(category,1) == "ROBO"

*Encoding crime, category, type and subtype
*encode crime, gen(crimeid)
encode category, gen(categoryid)
encode type, gen(typeid)
encode subtype, gen(subtypeid)
label define categoryid 11 "ROBO TOTAL", add
label define categoryid 0"INCIDENCIA DELICTIVA", add
label define typeid 19 "TOTAL",add
label define subtypeid 30 "TOTAL",add

drop  category type subtype

order state*  year *id 

destring ene-dic, replace force



save Impalmensual.dta, replace


***Totales con o sin violencia por suptipo de robo (Con o sin violencia (typeid))***

*Robo comun**

keep if categoryid == 7 | categoryid == 9 | categoryid == 10

collapse (sum)  ene-dic , by(state_code mun_code municip year categoryid subtypeid)
gen typeid:typeid = 19

order state* mun* year category type subtype

save robo.dta, replace 




************


use Impalmensual.dta, clear

***Totales por tipo***
*Total de despojo, homicidio doloso, homicidio culposo, lesiones dolosas, culposas y robo comun con y sin violencia, robo a casa habitaciom
** con y sin violencia, robo a isnt bancarias con y sin violencia**

keep if typeid == 8 | categoryid == 3 | categoryid == 4| categoryid == 7 | categoryid == 9 | categoryid == 10

collapse (sum)  ene-dic  , by(state_code mun_code municip year categoryid typeid)
gen subtypeid:subtypeid = 30
order state* mun* year category type subtype

save types.dta, replace




******************
** totales por categoria***

use Impalmensual.dta, clear

drop if categoryid == 1 | categoryid == 2 |categoryid == 6 | categoryid == 8
collapse (sum)  ene-dic  , by(state_code mun_code municip year categoryid)

gen subtypeid:subtypeid = 30

gen typeid:typeid = 19

order state* mun* year category type subtype

save categorias.dta, replace

*** total robo **
use Impalmensual.dta, clear
keep if categoryid >6
collapse (sum)  ene-dic  , by(state_code mun_code municip year typeid)
gen dummy = 1 if typeid ==1 | typeid == 17
replace dummy = 2 if dummy == .
collapse (sum)  ene-dic  , by(state_code mun_code municip year dummy)
gen categoryid:categoryid = 11
gen typeid:typeid =4 if dummy == 2
replace typeid =17 if dummy ==1
gen subtypeid:subtypeid =30
drop dummy
save roboviolenciatotal.dta, replace
collapse (sum)  ene-dic  , by(state_code mun_code municip year categoryid subtypeid)
gen typeid:typeid =19
save robototal.dta, replace 


** total delitos**
 use Impalmensual.dta, clear
collapse (sum)  ene-dic  , by(state_code mun_code municip year)
gen categoryid:categoryid=0
gen typeid:typeid=19
gen subtypeid:subtypeid=30
save total.dta, replace

clear
append using "Impalmensual.dta" "robo.dta" "types.dta" "categorias.dta" "roboviolenciatotal.dta" "robototal.dta" "total.dta"

order state* mun* year category type subtype
sort mun_code  year category type subtype 

save Impalmensual.dta, replace


**tasas***

***REVISAR QUE HACER CON NO ESPECIFICADO Y OTROS MUNICIPIOS
merge m:1 year mun_code using munpop.dta
drop if  _merge == 1 | _merge == 2
drop _merge 

save Impalmensual.dta, replace



**

drop pop
reshape wide ene-dic, i(state_code  municip  categoryid typeid subtypeid  mun_code ) j(year)


*cálculos mensuales, triemstrlaes, etc***

forvalues i = 2011/2016 {
egen t1`i' = rowtotal (ene`i' feb`i' mar`i')
egen t2`i' = rowtotal (abr`i' may`i' jun`i')
egen t3`i' = rowtotal (jul`i' ago`i' sep`i')
egen t4`i' = rowtotal (oct`i' nov`i' dic`i')
}

forvalues i = 2011/2016 {
egen c1`i' = rowtotal (ene`i' feb`i' mar`i' abr`i')
egen c2`i' = rowtotal (may`i' jun`i' jul`i' ago`i')
egen c3`i' = rowtotal (sep`i' oct`i' nov`i' dic`i')
}

forvalues i = 2011/2016 {
egen s1`i' = rowtotal (ene`i' feb`i' mar`i' abr`i' may`i' jun`i')
egen s2`i' = rowtotal (jul`i' ago`i' sep`i' oct`i' nov`i' dic`i')
}

forvalues i = 2011/2016 {
egen a`i' = rowtotal (ene`i' feb`i' mar`i' abr`i' may`i' jun`i' jul`i' ago`i' sep`i' oct`i' nov`i' dic`i')
}

save "$mun/municip_total.dta", replace


use Impalmensual.dta, clear

foreach var of varlist ene-dic {
	gen t`var' = (`var' * 100000)/ pop
}


drop ene-dic pop

reshape wide tene-tdic, i(state_code  municip  categoryid typeid subtypeid  mun_code ) j(year)



*cálculos mensuales, triemstrlaes, etc***

forvalues i = 2011/2016 {
egen t_t1`i' = rowtotal (tene`i' tfeb`i' tmar`i')
egen t_t2`i' = rowtotal (tabr`i' tmay`i' tjun`i')
egen t_t3`i' = rowtotal (tjul`i' tago`i' tsep`i')
egen t_t4`i' = rowtotal (toct`i' tnov`i' tdic`i')
}

forvalues i = 2011/2016 {
egen t_c1`i' = rowtotal (tene`i' tfeb`i' tmar`i' tabr`i')
egen t_c2`i' = rowtotal (tmay`i' tjun`i' tjul`i' tago`i')
egen t_c3`i' = rowtotal (tsep`i' toct`i' tnov`i' tdic`i')
}

forvalues i = 2011/2016 {
egen t_s1`i' = rowtotal (tene`i' tfeb`i' tmar`i' tabr`i' tmay`i' tjun`i')
egen t_s2`i' = rowtotal (tjul`i' tago`i' tsep`i' toct`i' tnov`i' tdic`i')
}

forvalues i = 2011/2016 {
egen t_a`i' = rowtotal (tene`i' tfeb`i' tmar`i' tabr`i' tmay`i' tjun`i' tjul`i' tago`i' tsep`i' toct`i' tnov`i' tdic`i')
}


save "$mun/municip_rate.dta", replace


use munpop.dta, clear
reshape wide pop, i(mun_code ) j(year)

save munpop.dta, replace

use "../municip_total.dta", clear

keep if categoryid == 0
sort mun_code
quietly by mun_code: gen dup = cond(_N==1,0,_n)
drop if dup == 1

keep state_code mun_code municip
merge 1:1 mun_code using munpop.dta

drop _merge

save poblacionmun.dta, replace

****** Zonas Metropolitanas***************************************************

cd "$rates/Metro Zones/Files"


copy "http://onc.org.mx/wp-content/uploads/2016/12/MaestroCodigosMunicipios.dta_.zip" MaestroCodigosMunicipios.zip, replace
unzipfile "MaestroCodigosMunicipios.zip", replace


use "$rates/Metro Zones/Files/MaestroCodigosMunicipios.dta"
keep mun_code am
save "$rates/Metro Zones/Files/codigos_zm.dta", replace


use "$mun/Files/Impalmensual.dta", clear
merge m:m mun_code using "$rates/Metro Zones/Files/codigos_zm.dta"

drop if am == .
drop _merge

order state_code  mun_code municip am categoryid typeid subtypeid 

collapse (sum) ene-pop, by(am categoryid typeid subtypeid  year)

save Izmmensual.dta, replace


drop pop
reshape wide ene-dic, i(am   categoryid typeid subtypeid  ) j(year)

*cálculos mensuales, triemstrlaes, etc***

forvalues i = 2011/2016 {
egen t1`i' = rowtotal (ene`i' feb`i' mar`i')
egen t2`i' = rowtotal (abr`i' may`i' jun`i')
egen t3`i' = rowtotal (jul`i' ago`i' sep`i')
egen t4`i' = rowtotal (oct`i' nov`i' dic`i')
}

forvalues i = 2011/2016 {
egen c1`i' = rowtotal (ene`i' feb`i' mar`i' abr`i')
egen c2`i' = rowtotal (may`i' jun`i' jul`i' ago`i')
egen c3`i' = rowtotal (sep`i' oct`i' nov`i' dic`i')
}

forvalues i = 2011/2016 {
egen s1`i' = rowtotal (ene`i' feb`i' mar`i' abr`i' may`i' jun`i')
egen s2`i' = rowtotal (jul`i' ago`i' sep`i' oct`i' nov`i' dic`i')
}

forvalues i = 2011/2016 {
egen a`i' = rowtotal (ene`i' feb`i' mar`i' abr`i' may`i' jun`i' jul`i' ago`i' sep`i' oct`i' nov`i' dic`i')
}


save "$rates/Metro Zones/zm_total.dta", replace


use Izmmensual.dta,clear

foreach var of varlist ene-dic {
	gen t`var' = (`var' * 100000)/ pop
}


drop ene-dic pop

reshape wide tene-tdic, i(am    categoryid typeid subtypeid   ) j(year)



*cálculos mensuales, triemstrlaes, etc***

forvalues i = 2011/2016 {
egen t_t1`i' = rowtotal (tene`i' tfeb`i' tmar`i')
egen t_t2`i' = rowtotal (tabr`i' tmay`i' tjun`i')
egen t_t3`i' = rowtotal (tjul`i' tago`i' tsep`i')
egen t_t4`i' = rowtotal (toct`i' tnov`i' tdic`i')
}

forvalues i = 2011/2016 {
egen t_c1`i' = rowtotal (tene`i' tfeb`i' tmar`i' tabr`i')
egen t_c2`i' = rowtotal (tmay`i' tjun`i' tjul`i' tago`i')
egen t_c3`i' = rowtotal (tsep`i' toct`i' tnov`i' tdic`i')
}

forvalues i = 2011/2016 {
egen t_s1`i' = rowtotal (tene`i' tfeb`i' tmar`i' tabr`i' tmay`i' tjun`i')
egen t_s2`i' = rowtotal (tjul`i' tago`i' tsep`i' toct`i' tnov`i' tdic`i')
}

forvalues i = 2011/2016 {
egen t_a`i' = rowtotal (tene`i' tfeb`i' tmar`i' tabr`i' tmay`i' tjun`i' tjul`i' tago`i' tsep`i' toct`i' tnov`i' tdic`i')
}


save "$rates/Metro Zones/zm_rate.dta", replace
rm "$rates/Metro Zones/Files/Izmmensual.dta"
rm MaestroCodigosMunicipios.zip
************


cd "$mun/Files/"
rm Impalmensual.dta
rm robo.dta
rm robototal.dta
rm roboviolenciatotal.dta
rm categorias.dta
rm total.dta
rm types.dta
rm delitos-fuero-comun.dta
rm incidencia_m.zip
rm "Incidencia Delictiva FC Municipal 2011 - 2016.xlsx"
rm "munpop.csv"
rm "IncidenciaDelictivaMunicipal.xlsx"


do "https://www.dropbox.com/s/5dha846zoltulus/3.Analisis.do?dl=0"


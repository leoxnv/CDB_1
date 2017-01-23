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


* Part 3*

forvalues i = 0/32 {

use "$rates/States/state_rate.dta", clear
keep if (typeid ==10 & subtypeid== 16) |(typeid ==9 & subtypeid== 16) |subtypeid == 29 | subtypeid == 21 | (typeid == 10 & subtypeid == 30) | (typeid == 6 & subtypeid ==30) | categoryid == 6 | (categoryid == 11 & typeid == 4) |(subtypeid == 6 & typeid == 19) |(subtypeid == 8 & typeid == 19) |(subtypeid == 19 & typeid == 19) | categoryid == 0 |(subtypeid == 9 & typeid == 19) 


label define crimeid 1930	"Total de delitos", add
label define crimeid 1221	"Extorsión" , add
label define crimeid 630	"Homicidio culposo", add
label define crimeid 1030	"Homicidio doloso", add
label define crimeid 1626	"Secuestro", add
label define crimeid 196	"Robo a casa habitación", add
label define crimeid 198	"Robo a negocio", add
label define crimeid 1919	"Robo de Vehículos", add
label define crimeid 430	"Robo total con violencia", add
label define crimeid 199	"Robo a transeúnte", add
label define crimeid 1829	"Violacion", add
label define crimeid 916	"Lesiones con arma fuego", add
label define crimeid 1016	"Homicidio doloso con arma de fuego", add



egen crimeid = concat( typeid subtypeid)
destring crimeid, replace
label val crimeid crimeid 
drop categoryid typeid subtypeid


***cambiar codigo de estado***
*Códigos por Estado



keep if state_code == `i'
order crimeid 

local ds0 "nacional.xlsx"
local ds1 "ags.xlsx"
local ds2 "bc.xlsx"
local ds3 "bcs.xlsx"
local ds4 "camp.xlsx"
local ds5 "coah.xlsx"
local ds6 "col.xlsx"
local ds7 "chis.xlsx"
local ds8 "chih.xlsx"
local ds9 "cdmx.xlsx"
local ds10 "dgo.xlsx"
local ds11 "gto.xlsx"
local ds12 "guerr.xlsx"
local ds13 "hgo.xlsx"
local ds14 "jal.xlsx"
local ds15 "mex.xlsx"
local ds16 "mich.xlsx"
local ds17 "mor.xlsx"
local ds18 "nay.xlsx"
local ds19 "nl.xlsx"
local ds20 "oax.xlsx"
local ds21 "pue.xlsx"
local ds22 "qto.xlsx"
local ds23 "qroo.xlsx"
local ds24 "slp.xlsx"
local ds25 "sin.xlsx"
local ds26 "son.xlsx"
local ds27 "tab.xlsx"
local ds28 "tamps.xlsx"
local ds29 "tlax.xlsx"
local ds30 "ver.xlsx"
local ds31 "yuc.xlsx"
local ds32 "zac.xlsx"

export excel crimeid  t_a1997-t_a2016  using "$analisis/States/`ds`i''", sheet("tasaanual") sheetmodify cell(A1) firstrow(varlabels) 
export excel crimeid  tene1997-tdic2016  using "$analisis/States/`ds`i''", sheet("tasamensual") sheetmodify cell(A1) firstrow(varlabels)
export excel crimeid  t_t11997-t_t42016  using "$analisis/States/`ds`i''", sheet("tasatrimestral") sheetmodify cell(A1) firstrow(varlabels)
export excel crimeid  t_c11997-t_c32016  using "$analisis/States/`ds`i''", sheet("tasacuatrimestral") sheetmodify cell(A1) firstrow(varlabels)
export excel crimeid  t_s11997-t_s22016  using "$analisis/States/`ds`i''", sheet("tasasemestral") sheetmodify cell(A1) firstrow(varlabels)


use "$rates/States/state_total.dta", clear
keep if (typeid ==10 & subtypeid== 16) |(typeid ==9 & subtypeid== 16) |subtypeid == 29 | subtypeid == 21 | (typeid == 10 & subtypeid == 30) | (typeid == 6 & subtypeid ==30) | categoryid == 6 | (categoryid == 11 & typeid == 4) |(subtypeid == 6 & typeid == 19) |(subtypeid == 8 & typeid == 19) |(subtypeid == 19 & typeid == 19) | categoryid == 0 |(subtypeid == 9 & typeid == 19) 


label define crimeid 1930	"Total de delitos", add
label define crimeid 1221	"Extorsión" , add
label define crimeid 630	"Homicidio culposo", add
label define crimeid 1030	"Homicidio doloso", add
label define crimeid 1626	"Secuestro", add
label define crimeid 196	"Robo a casa habitación", add
label define crimeid 198	"Robo a negocio", add
label define crimeid 1919	"Robo de Vehículos", add
label define crimeid 430	"Robo total con violencia", add
label define crimeid 199	"Robo a transeúnte", add
label define crimeid 1829	"Violacion", add
label define crimeid 916	"Lesiones con arma fuego", add
label define crimeid 1016	"Homicidio doloso con arma de fuego", add

egen crimeid = concat( typeid subtypeid)
destring crimeid, replace
label val crimeid crimeid 
drop categoryid typeid subtypeid

***cambiar codigo de estado***
keep if state_code == `i'

order crimeid 

export excel crimeid  a1997-a2016  using "$analisis/States/`ds`i''", sheet("absolutoanual") sheetmodify cell(A1) firstrow(varlabels) 
export excel crimeid  ene1997-dic2016  using "$analisis/States/`ds`i''", sheet("absolutomensual") sheetmodify cell(A1) firstrow(varlabels)
export excel crimeid  t11997-t42016  using "$analisis/States/`ds`i''", sheet("absolutotrimestral") sheetmodify cell(A1) firstrow(varlabels)
export excel crimeid  c11997-c32016  using "$analisis/States/`ds`i''", sheet("absolutocuatrimestral") sheetmodify cell(A1) firstrow(varlabels)
export excel crimeid  s11997-s22016  using "$analisis/States/`ds`i''", sheet("absolutosemestral") sheetmodify cell(A1) firstrow(varlabels)



use "$rates/States/state_rate.dta", clear

keep if (typeid ==10 & subtypeid== 16) |(typeid ==9 & subtypeid== 16) |subtypeid == 29 | subtypeid == 21 | (typeid == 10 & subtypeid == 30) | (typeid == 6 & subtypeid ==30) | categoryid == 6 | (categoryid == 11 & typeid == 4) |(subtypeid == 6 & typeid == 19) |(subtypeid == 8 & typeid == 19) |(subtypeid == 19 & typeid == 19) | categoryid == 0 |(subtypeid == 9 & typeid == 19) 

keep  state_code- subtypeid  t_a2014 t_a2015 t_a2016




label define crimeid 1930	"Total de delitos", add
label define crimeid 1221	"Extorsión" , add
label define crimeid 630	"Homicidio culposo", add
label define crimeid 1030	"Homicidio doloso", add
label define crimeid 1626	"Secuestro", add
label define crimeid 196	"Robo a casa habitación", add
label define crimeid 198	"Robo a negocio", add
label define crimeid 1919	"Robo de Vehículos", add
label define crimeid 430	"Robo total con violencia", add
label define crimeid 199	"Robo a transeúnte", add
label define crimeid 1829	"Violacion", add
label define crimeid 916	"Lesiones con arma fuego", add
label define crimeid 1016	"Homicidio doloso con arma de fuego", add

egen crimeid = concat( typeid subtypeid)
destring crimeid, replace
label val crimeid crimeid 
drop categoryid typeid subtypeid


 

reshape wide t_a2014 t_a2015 t_a2016, i(state_code) j(crimeid)

rename (t_a20161930 t_a20161221 t_a2016630 t_a20161030 t_a20161626 t_a2016196 t_a2016198 t_a20161919 t_a2016430 t_a2016199 t_a2016916 t_a20161829)(Total16 Extorsion16 Culposos16 Dolosos16 Secuestro16 casa16 negocio16 vehiculo16 robo_violencia16 transeunte16 lesionesfuego16 violacion16)
rename (t_a20151930 t_a20151221 t_a2015630 t_a20151030 t_a20151626 t_a2015196 t_a2015198 t_a20151919 t_a2015430 t_a2015199 t_a2015916 t_a20151829)(Total15 Extorsion15 Culposos15 Dolosos15 Secuestro15 casa15 negocio15 vehiculo15 robo_violencia15 transeunte15 lesionesfuego15 violacion15)
rename (t_a20141930 t_a20141221 t_a2014630 t_a20141030 t_a20141626 t_a2014196 t_a2014198 t_a20141919 t_a2014430 t_a2014199 t_a2014916 t_a20141829)(Total14 Extorsion14 Culposos14 Dolosos14 Secuestro14 casa14 negocio14 vehiculo14 robo_violencia14 transeunte14 lesionesfuego14 violacion14)



foreach var of varlist *15 {
   	local newname = subinstr("`var'", substr("`var'",length("`var'")-1,.),"",.)
   gen dif`newname' =((`newname'16-`newname'15)/ `newname'15)*100
}


preserve

keep if state_code == 0

tempfile master
save `master'

restore




drop if state_code == 0
foreach var of varlist casa14-Total16 {
egen r_`var' = rank(`var'), f 
}

append using `master'



export excel using "$analisis/States/`ds`i''", sheet("rankings") sheetmodify cell(A1) firstrow(var) 

 use "$rates/States/Files/poblacionestados.dta", clear

export excel using "$analisis/States/`ds`i''", sheet("poblacion") sheetmodify cell(A1) firstrow(var) 


}


foreach i of numlist 1/32 {


local ds1 "mpos_ags.xlsx"
local ds2 "mpos_bc.xlsx"
local ds3 "mpos_bcs.xlsx"
local ds4 "mpos_camp.xlsx"
local ds5 "mpos_coah.xlsx"
local ds6 "mpos_col.xlsx"
local ds7 "mpos_chis.xlsx"
local ds8 "mpos_chih.xlsx"
local ds9 "mpos_cdmx.xlsx"
local ds10 "mpos_dgo.xlsx"
local ds11 "mpos_gto.xlsx"
local ds12 "mpos_guerr.xlsx"
local ds13 "mpos_hgo.xlsx"
local ds14 "mpos_jal.xlsx"
local ds15 "mpos_mex.xlsx"
local ds16 "mpos_mich.xlsx"
local ds17 "mpos_mor.xlsx"
local ds18 "mpos_nay.xlsx"
local ds19 "mpos_nl.xlsx"
local ds20 "mpos_oax.xlsx"
local ds21 "mpos_pue.xlsx"
local ds22 "mpos_qto.xlsx"
local ds23 "mpos_qroo.xlsx"
local ds24 "mpos_slp.xlsx"
local ds25 "mpos_sin.xlsx"
local ds26 "mpos_son.xlsx"
local ds27 "mpos_tab.xlsx"
local ds28 "mpos_tamps.xlsx"
local ds29 "mpos_tlax.xlsx"
local ds30 "mpos_ver.xlsx"
local ds31 "mpos_yuc.xlsx"
local ds32 "mpos_zac.xlsx"


	foreach x in 196 198 199 430 630 1030 1221 1626 1919 1930 1829 916 {
		use "/Users/leoxnv/Dropbox/Crime rates in Mexico/Municipalities/municip_rate.dta", clear

		keep if state_code == `i'

keep if (typeid ==10 & subtypeid== 16) |(typeid ==9 & subtypeid== 16) |subtypeid == 29 | subtypeid == 21 | (typeid == 10 & subtypeid == 30) | (typeid == 6 & subtypeid ==30) | categoryid == 6 | (categoryid == 11 & typeid == 4) |(subtypeid == 6 & typeid == 19) |(subtypeid == 8 & typeid == 19) |(subtypeid == 19 & typeid == 19) | categoryid == 0 |(subtypeid == 9 & typeid == 19) 


label define crimeid 1930	"Total de delitos", add
label define crimeid 1221	"Extorsión" , add
label define crimeid 630	"Homicidio culposo", add
label define crimeid 1030	"Homicidio doloso", add
label define crimeid 1626	"Secuestro", add
label define crimeid 196	"Robo a casa habitación", add
label define crimeid 198	"Robo a negocio", add
label define crimeid 1919	"Robo de Vehículos", add
label define crimeid 430	"Robo total con violencia", add
label define crimeid 199	"Robo a transeúnte", add
label define crimeid 1829	"Violacion", add
label define crimeid 916	"Lesiones con arma fuego", add
label define crimeid 1016	"Homicidio doloso con arma de fuego", add

		egen crimeid = concat( typeid subtypeid)
		destring crimeid, replace
		label val crimeid crimeid 
		drop categoryid typeid subtypeid
		local d196 "casahab"
		local d198 "negocio"
		local d199 "transeunte"
		local d430 "Roboviolencia"
		local d630 "culposo"
		local d1030 "doloso"
		local d1221 "extorsion"
		local d1626 "secuestro"
		local d1919 "vehiculos"
		local d1930 "totaldel"
		local d1829 "violacion"
		local d916 "lesionesfuego"

		keep if crimeid== `x'
		order crimeid 
		egen suma_rate = rowtotal(t_a2011-t_a2016) 

		foreach var of varlist t_a2015-suma_rate {
			egen r_`var' = rank(`var'), f 
		}

		export excel crimeid mun_code municip t_a2011- r_suma_rate  using "$analisis/Municipalities/`ds`i''", sheet("anual`d`x''") sheetmodify cell(A1) firstrow(varlabels)
		export excel crimeid mun_code municip tene2011-tdic2016  using "$analisis/Municipalities/`ds`i''", sheet("mensual`d`x''") sheetmodify cell(A1) firstrow(varlabels) 

		use "/Users/leoxnv/Dropbox/Crime rates in Mexico/Municipalities/municip_total.dta", clear

		keep if state_code == `i'

keep if (typeid ==10 & subtypeid== 16) |(typeid ==9 & subtypeid== 16) |subtypeid == 29 | subtypeid == 21 | (typeid == 10 & subtypeid == 30) | (typeid == 6 & subtypeid ==30) | categoryid == 6 | (categoryid == 11 & typeid == 4) |(subtypeid == 6 & typeid == 19) |(subtypeid == 8 & typeid == 19) |(subtypeid == 19 & typeid == 19) | categoryid == 0 |(subtypeid == 9 & typeid == 19) 


label define crimeid 1930	"Total de delitos", add
label define crimeid 1221	"Extorsión" , add
label define crimeid 630	"Homicidio culposo", add
label define crimeid 1030	"Homicidio doloso", add
label define crimeid 1626	"Secuestro", add
label define crimeid 196	"Robo a casa habitación", add
label define crimeid 198	"Robo a negocio", add
label define crimeid 1919	"Robo de Vehículos", add
label define crimeid 430	"Robo total con violencia", add
label define crimeid 199	"Robo a transeúnte", add
label define crimeid 1829	"Violacion", add
label define crimeid 916	"Lesiones con arma fuego", add
label define crimeid 1016	"Homicidio doloso con arma de fuego", add

		egen crimeid = concat( typeid subtypeid)
		destring crimeid, replace
		label val crimeid crimeid 
		drop categoryid typeid subtypeid


		local d196 "casahab"
		local d198 "negocio"
		local d199 "transeunte"
		local d430 "Roboviolencia"
		local d630 "culposo"
		local d1030 "doloso"
		local d1221 "extorsion"
		local d1626 "secuestro"
		local d1919 "vehiculos"
		local d1930 "totaldel"
		local d1829 "violacion"
		local d916 "lesionesfuego"

		order crimeid 
		keep if crimeid== `x'

		egen suma_tot = rowtotal(a2011-a2016) 

		foreach var of varlist a2015-suma_tot {
			egen r_`var' = rank(`var'), f 
		}



		export excel  a2011-r_suma_tot  using "$analisis/Municipalities/`ds`i''", sheet("anual`d`x''") sheetmodify cell(O1) firstrow(varlabels)
		export excel crimeid mun_code municip ene2011-dic2016  using "$analisis/Municipalities/`ds`i''", sheet("mensual`d`x''") sheetmodify cell(A76) firstrow(varlabels) 
		
		use "/Users/leoxnv/Dropbox/Crime rates in Mexico/Municipalities/Files/poblacionmun.dta", clear

		keep if state_code == `i'
		export excel  state_code-pop2016  using "$analisis/Municipalities/`ds`i''", sheet("poblacion") sheetmodify  firstrow(varlabels)

		
		
	}
}


log close

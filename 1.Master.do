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
log using "$rates/Logs/`logdate'_update.log", replace
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

/* If the program is not running for the first time, Stata will promt some 
   errors while creating the directories. That is because they were created 
   before. Stata will ignore them, so will you.   					*/



*Downloading datasets. The program needs at least 2.5 GB of Hard Disk free space

/*IMPORTANT:After the 20th of each month check the new URL in SESNSP site and  
			1)Change updated URLs in /*1*/ & /*3*/ 
			2)Chamge updated files names in /*2*/ & /*4*/					*/
			
cd "$states/Files"
/*1*/ copy "http://secretariadoejecutivo.gob.mx/docs/pdfs/incidencia%20delictiva%20del%20fuero%20comun/IncidenciaDelictiva_FueroComun_Estatal_1997-122016.zip" incidencia_e.zip, replace
		unzipfile "incidencia_e.zip", replace
		
copy "IncidenciaDelictiva_FueroComun_Estatal_1997-2016.xlsb" "$prevst/IncidenciaDelictiva_FueroComun_Estatal_$S_DATE.xlsb"
		
copy "https://raw.githubusercontent.com/diegovalle/conapo-2010/master/clean-data/state-population.csv" statepop.csv

		
cd "$mun/Files"	
/*3*/ copy "http://secretariadoejecutivo.gob.mx/docs/pdfs/incidencia%20delictiva%20del%20fuero%20comun/IncidenciaDelictiva-Municipal2011-122016.zip" incidencia_m.zip, replace
	unzipfile "incidencia_m.zip", replace
copy "https://raw.githubusercontent.com/diegovalle/conapo-2010/master/clean-data/municipio-population2010-2030.csv" munpop.csv, replace

copy "Incidencia Delictiva FC Municipal 2011 - 2016.xlsb" "$prevmp/Incidencia Delictiva FC Municipal$S_DATE.xlsb"

	
exit

do "https://www.dropbox.com/s/eiisp35ge3mzujx/2.Process.do"



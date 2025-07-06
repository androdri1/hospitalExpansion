*************************************************************
*							AGORA_V4						*					
*							CAP HOS							*
*							2024							*
*							Analisis de la expasnion de las caapcidades hospitalarias en Colombia como respuesta al Covid									*	
*************************************************************

clear all
set type double

*cd "C:\Users\dalya\OneDrive - Universidad del rosario\AGORA\REPS"
*cd "D:\Paul.Rodriguez\Universidad del rosario\Dalya Sofia Rua Murcia - AGORA\REPS"
cd "C:\Users\paul.rodriguez\Universidad del rosario\AGORA Proyecto 4 - Documentos\Capacidad hospitalaria\Carpeta Sofia\REPS"
*cd "C:\Users\paul.rodriguez\Universidad del rosario\Dalya Sofia Rua Murcia - AGORA\REPS"
*cd "C:\Users\Catalina\OneDrive - Universidad del rosario\AGORA\REPS"

/*
******************************************************* Corrección Base ******************************************
	import excel "REPS.xlsx", firstrow allstring clear


	replace numero_sede_principal = "0" + numero_sede_principal if length(numero_sede_principal) ==1
	bys Año: gen codigo_hospital =  Códigosede + numero_sede_principal

	gen cod_mpo =substr(codigo_hospital,1, 5) if length(codigo_hospital)==12
	replace  cod_mpo =substr(codigo_hospital,1, 5) if length(codigo_hospital)==10
	replace  cod_mpo =substr(codigo_hospital,1, 5) if length(codigo_hospital)==11


	keep Año codigo_hospital cod_mpo Cantidad  GrupoNombreCapacidad Grupocapacidad Naturalezajurídica
	duplicates drop

	unique Año   Cantidad GrupoNombreCapacidad codigo_hospital
	*Number of unique values of Año Cantidad GrupoNombreCapacidad codigo_hospital is  192409
	*Number of records is  192409

	destring Año, replace
	destring Cantidad, replace
	
	egen id =  group(  GrupoNombreCapacidad codigo_hospital)
	
	collapse (sum) Cantidad , by(Año cod_mpo codigo_hospital Grupocapacidad GrupoNombreCapacidad id Naturalezajurídica )
	

	sort  Año codigo_hospital


	xtset  id Año
	tsfill, full
	
	encode GrupoNombreCapacidad, gen(GrupoNombreCapacidad2)
	bys id: egen aux = max(GrupoNombreCapacidad2)
	bys id: replace GrupoNombreCapacidad2 = aux
	drop aux
	drop GrupoNombreCapacidad 
	
	decode  GrupoNombreCapacidad2, gen(GrupoNombreCapacidad)
	
	** hacer exactamente lo mismo con naturaleza
	
	
	
	

* nuevas variables 


	gen SI = 1 if strpos(GrupoNombreCapacidad, "Adulto") > 0 &  strpos(Grupocapacidad, "CAMAS")
	egen aux_camas = count(GrupoNombreCapacidad) if SI ==1

	gen SI2 = 1 if strpos(GrupoNombreCapacidad, "Pedi") > 0 &  strpos(Grupocapacidad, "CAMAS")
	tab GrupoNombreCapacidad if SI2 ==1

	gen a_2019 = Cantidad > 0 & Cantidad < .  if Año==2019 
	bys GrupoNombreCapacidad  codigo_hospital: egen muestra_2019 = max(a_2019)
	
	gen naturaleza = 1 if  Naturalezajurídica == "Privada"
	replace naturaleza = 0 if  Naturalezajurídica == "Pública"
	encode codigo_hospital, generate(codigo_hospital2)
	
	bys id: egen aux = max(naturaleza)
	bys id: replace naturaleza = aux
	drop aux


	save "CAPACIDAD", replace
	
	
	* Conteo de prestadores
	use "CAPACIDAD", clear
	keep if Año==2019
	keep if Cantidad!=.
	keep if Grupocapacidad!=""
	keep codigo_hospital cod_mpo
	duplicates drop
	count  // 4,357
	duplicates drop cod_mpo, force
	count // 1,096
	
	use "CAPACIDAD", clear
	keep if Año==2019
	keep if Cantidad!=.
	keep if Grupocapacidad=="CAMAS"
	keep codigo_hospital cod_mpo
	duplicates drop
	count  // 1,797
	duplicates drop cod_mpo, force
	count // 871
	
*/

***************************************************** Gráficas: contar la historia **************************************************

use "CAPACIDAD", clear

keep if SI ==1 | SI2 ==1
collapse (sum) total = Cantidad , by( Año GrupoNombreCapacidad )
			
twoway 	(tsline total if GrupoNombreCapacidad == "CAMAS-Cuidado Intensivo Adulto") ///				
		(tsline total if GrupoNombreCapacidad =="CAMAS-Cuidado Intermedio Adulto" , lp(dash) ) ///
		(tsline total if GrupoNombreCapacidad =="CAMAS-Adultos",  yaxis(2) lw(thick) ) ///
		,xline(2019) xlabel(2010(3)2023) legend(order ( 1 "Intensive Care Beds" 2 "Intermediate Care Beds" 3 "Hospital Beds" ) position(6)) ///
		xtitle("Years", size(10pt)) ///
		ytitle("Total Number of Intensive/Intermediate Care Beds", size(10pt)) ///
		ytitle("Total Number of Adult Beds", axis(2) size(10pt)) 
		
		*subtitle("Adult Beds 2010 - 2022", size(9pt)) note("Own calculations" "Information obtained from REPS - MSPS" ,size(7pt)) ///
		*title("National Hospital Capacity", size(12pt))  xmtick(##11) ymtick(##11) xsize(5)

		

*Verisón policy brief .....................................................		
twoway 	(tsline total if GrupoNombreCapacidad == "CAMAS-Cuidado Intensivo Adulto") ///				
		(tsline total if GrupoNombreCapacidad =="CAMAS-Cuidado Intermedio Adulto" , lp(dash) ) ///
		(tsline total if GrupoNombreCapacidad =="CAMAS-Adultos",  yaxis(2) lw(thick) ) ///
		,xline(2019) xlabel(2010(3)2023) legend(order ( 1 "Cuidado intensivo" 2 "Cuidado intermedio" 3 "Camas hospitalización adultos" ) position(6) cols(3)) ///
		xtitle("Años", size(10pt)) ///
		ytitle("Númerocamas de cuidado inesive/intermedio", size(10pt)) ///
		ytitle("Número de camas de adultos", axis(2) size(10pt)) scheme(gg_hue)
				
* .........................................................

use "CAPACIDAD", clear
keep if muestra_2019 == 1
keep if SI ==1 | SI2 ==1
collapse (mean) total = Cantidad , by( Año GrupoNombreCapacidad  )

twoway  (tsline total if GrupoNombreCapacidad =="CAMAS-Cuidado Intensivo Adulto") ///
		(tsline total if GrupoNombreCapacidad =="CAMAS-Cuidado Intermedio Adulto" , lp(dash)) ///
		(tsline total if GrupoNombreCapacidad =="CAMAS-Adultos",  lw(thick)) ///				
		, xline(2019) xlabel(2010(3)2023)  legend(order ( 1 "Camas de Cuidado Intensivo" 2 "Camas Cuidado Intermedio" 3 "Camas de Hospitalización") position(6)) ///
		xtitle("Años", size(10pt)) ytitle(" Promedio  de Camas", size(10pt))subtitle(" Camas Adultos 2010 -2022", size(9pt)) ///
		note("Calculos propios" "Información obtenida de REPS - MSPS" ,size(7pt)) title("Capacidad Hospitalaria promedio por sede", size(12pt)) ///
		xmtick(##11) ymtick(##11)  xsize(4) ysize(5)




		
	
******************************************************************** MODELOS *************************************************************
use "CAPACIDAD", clear

keep if muestra_2019 == 1
destring cod_mpo , replace
tabulate Año, generate(a)
destring Año , replace

********************************************************************************
**# Modelo 1: solo años
********************************************************************************

*** Adultos

reghdfe Cantidad  a11 a12 a13 if GrupoNombreCapacidad =="CAMAS-Adultos", a(codigo_hospital i.cod_mpo#c.Año) cluster(cod_mpo)
estadd ysumm
estimates store adultos
outreg2 using "Modelo1.doc", excel replace addstat(Municipalities, e(N_clust), Mean, e(ymean) ) ctitle(A_Total)

reghdfe Cantidad  a11 a12 a13  if GrupoNombreCapacidad == "CAMAS-Cuidado Intermedio Adulto", a(codigo_hospital i.cod_mpo#c.Año) cluster(cod_mpo)
estadd ysumm
estimates store adultos_int
outreg2 using "Modelo1.doc", excel append addstat(Municipalities, e(N_clust), Mean, e(ymean) ) ctitle(A_Inter)
		
reghdfe Cantidad  a11 a12 a13 if GrupoNombreCapacidad == "CAMAS-Cuidado Intensivo Adulto", a(codigo_hospital i.cod_mpo#c.Año) cluster(cod_mpo)
estadd ysumm
estimates store adultos_intermedio
outreg2 using "Modelo1.doc", excel append addstat(Municipalities, e(N_clust), Mean, e(ymean) ) ctitle(A_UCI)

** Niños
eststo niños_uci: reghdfe Cantidad  a11 a12 a13 if GrupoNombreCapacidad == "CAMAS-Pediátrica", a(codigo_hospital i.cod_mpo#c.Año) cluster(cod_mpo)
estadd ysumm
outreg2 using "Modelo1.doc", excel append addstat(Municipalities, e(N_clust), Mean, e(ymean) ) ctitle(P_Total)

			
eststo niños_int: reghdfe Cantidad  a11 a12 a13 if GrupoNombreCapacidad =="CAMAS-Cuidado Intermedio Pediátrico", a(codigo_hospital i.cod_mpo#c.Año) cluster(cod_mpo)
estadd ysumm
outreg2 using "Modelo1.doc", excel append addstat(Municipalities, e(N_clust), Mean, e(ymean) ) ctitle(P_Inter)

			
eststo niños: reghdfe Cantidad  a11 a12 a13 if GrupoNombreCapacidad =="CAMAS-Cuidado Intensivo Pediátrico", a(codigo_hospital i.cod_mpo#c.Año) cluster(cod_mpo)
estadd ysumm
outreg2 using "Modelo1.doc", excel append addstat(Municipalities, e(N_clust), Mean, e(ymean) ) ctitle(P_UCI)


****Modelo 2: Publico VS Privado 


use "CAPACIDAD", clear
keep if muestra_2019 ==1
keep if SI == 1 | SI2 ==1 
collapse(sum) Cantidad, by(Año GrupoNombreCapacidad codigo_hospital  naturaleza cod_mpo )
tabulate Año, generate(a)
destring  Año, replace
destring  cod_mpo, replace
				

reghdfe Cantidad  a11 a12 a13 if GrupoNombreCapacidad =="CAMAS-Adultos", a(codigo_hospital i.cod_mpo#c.Año) cluster(cod_mpo)
estadd ysumm
estimates store adultos
outreg2 using "Modelo2.doc", excel replace addstat(Municipalities, e(N_clust), Mean, e(ymean) ) ctitle(A_Total)

reghdfe Cantidad  a11 a12 a13 if GrupoNombreCapacidad == "CAMAS-Cuidado Intensivo Adulto", a(codigo_hospital i.cod_mpo#c.Año) cluster(cod_mpo)
estadd ysumm
estimates store adultos_intermedio
outreg2 using "Modelo2.doc", excel append addstat(Municipalities, e(N_clust), Mean, e(ymean) ) ctitle(A_UCI)

eststo camas_pub:	reghdfe Cantidad  a11 a12 a13  	if GrupoNombreCapacidad =="CAMAS-Adultos" & naturaleza ==0, a(codigo_hospital i.cod_mpo#c.Año) cluster(cod_mpo)
estadd ysumm
outreg2 using "Modelo2.doc", excel append addstat(Municipalities, e(N_clust), Mean, e(ymean) ) ctitle(A_Total_Pub)

eststo camas_pub_uci:	reghdfe Cantidad  a11 a12 a13  	if GrupoNombreCapacidad =="CAMAS-Cuidado Intensivo Adulto"  & naturaleza ==0, a(codigo_hospital i.cod_mpo#c.Año) cluster(cod_mpo)	
estadd ysumm
outreg2 using "Modelo2.doc", excel append addstat(Municipalities, e(N_clust), Mean, e(ymean) ) ctitle(A_UCI_Pub)

eststo camas_priv:	reghdfe Cantidad  a11 a12 a13  	if GrupoNombreCapacidad =="CAMAS-Adultos" & naturaleza ==1, a(codigo_hospital i.cod_mpo#c.Año) cluster(cod_mpo)
estadd ysumm
outreg2 using "Modelo2.doc", excel append addstat(Municipalities, e(N_clust), Mean, e(ymean) ) ctitle(A_Total_Priv)

eststo camas_priv_uci:	reghdfe Cantidad  a11 a12 a13  	if GrupoNombreCapacidad =="CAMAS-Cuidado Intensivo Adulto"  & naturaleza ==1, a(codigo_hospital i.cod_mpo#c.Año) cluster(cod_mpo)	
estadd ysumm
outreg2 using "Modelo2.doc", excel append addstat(Municipalities, e(N_clust), Mean, e(ymean) ) ctitle(A_UCI_Priv)
	

coun if 	GrupoNombreCapacidad =="CAMAS-Cuidado Intensivo Adulto"  & naturaleza ==0 & Año==2019 // 42 prestadores publicos con UCI en 2019
coun if 	GrupoNombreCapacidad =="CAMAS-Cuidado Intensivo Adulto"  & naturaleza ==1 & Año==2019 // 331 prestadores privados con UCI en 2019
	

********************************************************************************
**# Modelo 3: Grandes vs Pequeños
********************************************************************************

use "CAPACIDAD", clear
keep if muestra_2019 ==1
keep if SI == 1 | SI2 ==1 
collapse(sum) Cantidad, by(Año GrupoNombreCapacidad  cod_mpo codigo_hospital2 )
destring cod_mpo , replace
tabulate Año, generate(a)
destring Año , replace
levelsof GrupoNombreCapacidad, local (levels)
loc i =1
	
	
foreach capacidad in `levels' {	
	summarize Cantidad if Año ==2019 & GrupoNombreCapacidad == "`capacidad'", detail 
	local percentil_25 = r(p25)
	gen hospital_en_percentil_25 = (Cantidad <= `percentil_25') if Año == 2019 & GrupoNombreCapacidad == "`capacidad'"
	bys codigo_hospital2: egen h_25_`i' = max(hospital_en_percentil_25) 
	drop hospital_en_percentil_25
	loc i  = `i' +1		
}


levelsof GrupoNombreCapacidad, local (levels)
loc i =1	

foreach capacidad in `levels' {	
	summarize Cantidad if Año ==2019 & GrupoNombreCapacidad == "`capacidad'", detail 
	local percentil_75 = r(p75)
	gen hospital_en_percentil_75 = (Cantidad >= `percentil_75') if Año == 2019 & GrupoNombreCapacidad == "`capacidad'"
	bys codigo_hospital2: egen h_75_`i' = max(hospital_en_percentil_75) 
	drop hospital_en_percentil_75
	loc i  = `i' +1	
}

		
reghdfe Cantidad  a11 a12 a13 if GrupoNombreCapacidad =="CAMAS-Adultos", a(codigo_hospital i.cod_mpo#c.Año) cluster(cod_mpo)
estimates store adultos
estadd ysumm
outreg2 using "Modelo3.doc", excel replace addstat(Municipalities, e(N_clust), Mean, e(ymean) ) ctitle(A_total)

	
reghdfe Cantidad  a11 a12 a13 if GrupoNombreCapacidad == "CAMAS-Cuidado Intensivo Adulto", a(codigo_hospital i.cod_mpo#c.Año) cluster(cod_mpo)
estimates store adultos_intermedio
estadd ysumm
outreg2 using "Modelo3.xls", excel append addstat(Municipalities, e(N_clust), Mean, e(ymean) ) ctitle(A_UCI)
		
*h_25_1 = CAMAS-Adultos
eststo camas_25: reghdfe Cantidad  a11 a12 a13   if GrupoNombreCapacidad =="CAMAS-Adultos" & h_25_1 ==1 , a(codigo_hospital2 i.cod_mpo#c.Año) cluster(cod_mpo)
estadd ysumm
outreg2 using "Modelo3.doc", excel append addstat(Municipalities, e(N_clust), Mean, e(ymean) ) ctitle(A_total_peq)

*h_25_2 = CAMAS-Cuidado Intensivo Adulto
eststo camas_uci_25: reghdfe Cantidad  a11 a12 a13 if GrupoNombreCapacidad =="CAMAS-Cuidado Intensivo Adulto" & h_25_2 ==1, a(codigo_hospital2 i.cod_mpo#c.Año) cluster(cod_mpo)
estadd ysumm
outreg2 using "Modelo3.doc", excel append addstat(Municipalities, e(N_clust), Mean, e(ymean) ) ctitle(A_UCI_peq)
	


*** Intercalado 
*eststo camas_inter: reghdfe Cantidad  a11 a12 a13  c.a11#i.h_25_2 c.a12#i.h_25_2 c.a13#i.h_25_2 if GrupoNombreCapacidad =="CAMAS-Adultos"  , a(codigo_hospital2 i.cod_mpo#c.Año) cluster(cod_mpo)

		
*ADULTOS
		
eststo camas_75: reghdfe Cantidad  a11 a12 a13   if GrupoNombreCapacidad =="CAMAS-Adultos"   & h_75_1 ==1 , a(codigo_hospital2 i.cod_mpo#c.Año) cluster(cod_mpo)
estadd ysumm
outreg2 using "Modelo3.doc", append  addstat(Municipalities, e(N_clust), Mean, e(ymean) ) ctitle(A_total_gra)

eststo camas_uci_75: reghdfe Cantidad  a11 a12 a13   	if GrupoNombreCapacidad =="CAMAS-Cuidado Intensivo Adulto" & h_75_2 ==1 , a(codigo_hospital2 i.cod_mpo#c.Año) cluster(cod_mpo)
estadd ysumm
outreg2 using "Modelo3.doc", excel append addstat(Municipalities, e(N_clust), Mean, e(ymean) ) ctitle(A_UCI_gra)
	
	
********************************************************************************
**# Modelo 4: Tener camas a nivel de hospital
********************************************************************************

use "CAPACIDAD", clear
gen camas1 = 1 if Cantidad !=. & Grupocapacidad == "CAMAS" 
replace camas1 = 0 if camas1 ==.   

tabulate Año, generate(a)
destring Año, replace
destring cod_mpo, replace 

reghdfe camas1  a11 a12 a13   if GrupoNombreCapacidad =="CAMAS-Adultos" , a(codigo_hospital2 i.cod_mpo#c.Año) cluster(cod_mpo)
estadd ysumm
outreg2 using "Modelo4.doc", excel replace addstat(Municipalities, e(N_clust), Mean, e(ymean) ) ctitle(A_total)

reghdfe  camas1 a11 a12 a13  	if GrupoNombreCapacidad =="CAMAS-Cuidado Intermedio Adulto", a(codigo_hospital2 i.cod_mpo#c.Año) cluster(cod_mpo)
estadd ysumm
outreg2 using "Modelo4.doc", excel append addstat(Municipalities, e(N_clust), Mean, e(ymean) ) ctitle(A_Inter)

reghdfe camas1  a11 a12 a13  	if GrupoNombreCapacidad =="CAMAS-Cuidado Intensivo Adulto", a(codigo_hospital2 i.cod_mpo#c.Año) cluster(cod_mpo)
estadd ysumm
outreg2 using "Modelo4.doc", excel append addstat(Municipalities, e(N_clust), Mean, e(ymean) ) ctitle(A_UCI)
	
sum camas1 if GrupoNombreCapacidad =="CAMAS-Adultos" & Año==2019
sum camas1 if GrupoNombreCapacidad =="CAMAS-Adultos" & Año==2022
sum camas1 if GrupoNombreCapacidad =="CAMAS-Cuidado Intensivo Adulto" & Año==2019
sum camas1 if GrupoNombreCapacidad =="CAMAS-Cuidado Intensivo Adulto" & Año==2022
	
	
********************************************************************************
**# Modelo 5: Tener camas, a nivel de municipio
********************************************************************************
use "CAPACIDAD", clear
keep cod_mpo
duplicates drop
gen Año=2010
tempfile munis
save `munis'

use "CAPACIDAD", clear
drop if  Grupocapacidad==""
replace Cantidad=0 if Cantidad==.

collapse (sum) Cantidad , by(cod_mpo Año Grupocapacidad GrupoNombreCapacidad )

destring Año, replace
destring cod_mpo, replace 


preserve // *************
keep if GrupoNombreCapacidad =="CAMAS-Adultos"
merge 1:1 cod_mpo Año using `munis', nogen
xtset cod_mpo Año
tsfill, full
tabulate Año, generate(a)

replace Cantidad=0 if Cantidad==.

gen camas1 = Cantidad >0 

reghdfe camas1  a11 a12 a13 c.Año  , a(cod_mpo ) cluster(cod_mpo)
estadd ysumm
outreg2 using "Modelo5.xls", excel replace addstat(Municipalities, e(N_clust), Mean, e(ymean) ) ctitle(A_total)

sum camas1 if Año==2019
sum camas1 if Año==2022

sum Cantidad if Año==2019
sum Cantidad if Año==2022
restore

preserve // *************
keep if GrupoNombreCapacidad =="CAMAS-Cuidado Intensivo Adulto"
merge 1:1 cod_mpo Año using `munis', nogen
xtset cod_mpo Año
tsfill, full
tabulate Año, generate(a)

replace Cantidad=0 if Cantidad==.

gen camas1 = Cantidad >0 

reghdfe camas1  a11 a12 a13 c.Año  , a(cod_mpo ) cluster(cod_mpo)
estadd ysumm
outreg2 using "Modelo5.doc", excel append addstat(Municipalities, e(N_clust), Mean, e(ymean) ) ctitle(A_UCI)

sum camas1 if Año==2019
sum camas1 if Año==2022

sum Cantidad if Año==2019
sum Cantidad if Año==2022
restore

	
	
	
* 1. Overleaf
* 6. - Divisón según territorios, algo así, a nivel de departamento/region.
* 7. ¿Algo espacial? Distancia del municpio a la UCI más cercana








	
	
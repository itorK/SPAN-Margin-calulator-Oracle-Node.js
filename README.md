# SPAN-Margin-calulator-Oracle-Node.js
Kalkulator depozytów SPAN® dla bazy Oracle (PL/SQL) oraz Import danych z pliku KDPW do bazy Oracle(Node.js)

==================
Implementacja algorytmu według przepisów na stronie KDPW <br>
http://www.kdpwccp.pl/pl/zarzadzanie/span/Strony/O-SPAN.aspx

Algorytm zwraca wartości identyczne z Kalkulatorem KDPW<br>
http://www.kdpwccp.pl/pl/zarzadzanie/Strony/kalkulator.aspx

Instalacja Importu
-----------

1. Należy zainstalować Node.js

http://nodejs.org/

2. Pobieramy plik import.js z obecnego projektu
3. Pod katalogiem projektu uruchamiamy polecenia

``` 
npm install xpath.js
npm install xmldom
``` 

4. Najtrudniejsza sprawa to zainstalowanie sterownika Oracle dla Node.js wg poniższego przepisu
https://github.com/joeferner/node-oracle

5. Należy pobrać plik pk_import.pck oraz załadować pakiet do Oracla poprzez sqlplus-a

``` 
SQL> @pk_import.pck;
``` 


Instalacja Kalkulatora
-----------

1. Pobieramy pliki span_schema.pck,pk_span.pck oraz uruchamiamy 
``` 
SQL> @span_schema.pck;
SQL> @pk_span.pck;
``` 

Użycie - Import
-----------

1. W katalogu projektu uruchamiamy polecenie:
``` 
node import.js
``` 

Powyższe polecenie pobierze najnowyszy plik RPNJI_ZRS.xml ze strony KDPW i umieści dane w bazie


Użycie - Kalkulacja
-----------



``` 
PROCEDURE prExample IS
depozyt DECIMAL(15,2);
v_NOD  NUMBER(15,2);
v_PNO  NUMBER(15,2);
v_PO  NUMBER(15,2);
begin
pk_span.prCzysc();
pk_span.prDodajPozycje('FW20Z1420',8,4.5);
pk_span.prDodajPozycje('FW20U1520',-2,4.5);
pk_span.prOblDep(depozyt,v_NOD,v_PNO,v_PO);
end prTest;
``` 


Źródła
-----------

[KDPW SPAN](http://www.kdpwccp.pl/pl/zarzadzanie/span/Documents/SPAN_depozyty_dla_kontrakt%C3%B3w_terminowych/SPAN_depozyty_dla_kontraktow_terminowych.pdf) 

Autor
-----------
[Karol Przybylski](http://www.esm-technology.pl) <br>
karol.przybylski@esm-technology.pl
``` 

CREATE OR Replace package pk_span As
FUNCTION oblIntra
   RETURN decimal;
FUNCTION oblInter
   RETURN decimal;
PROCEDURE prOblDep (p_depozyt OUT NUMBER,
	p_NOD  OUT NUMBER,
	p_PNO  OUT NUMBER,
	p_PO  OUT NUMBER);
FUNCTION fnPNO
	return number;
FUNCTION fnPO
	return number;
FUNCTION fnMDKO
	return number;
FUNCTION dajStatus
   RETURN varchar2;
PROCEDURE prDodajPozycje(p_symbol VARCHAR2,p_ilosc NUMBER, p_cena_jedn DECIMAL);
PROCEDURE prTest;
PROCEDURE prCzysc;
END pk_span;
/

CREATE OR Replace package body pk_span As
new_status  VARCHAR2(70) := 'OK';

   TYPE rec_klasa_t IS RECORD (
      klas_id NUMBER,
      nr_poziomu NUMBER,
      tdU DECIMAL(15,2),
      tdD DECIMAL(15,2),
      wartosc DECIMAL(15,2));
   TYPE klasy_t IS TABLE OF rec_klasa_t
      INDEX BY BINARY_INTEGER;

FUNCTION dajStatus
   RETURN varchar2 IS
begin
return new_status;
end dajStatus;


FUNCTION oblInter
   RETURN decimal IS
suma decimal(15,2);
i NUMBER;
i1 NUMBER;
i2 NUMBER;
scen NUMBER;
tdD1 DECIMAL(15,5);
tdU1 DECIMAL(15,5);
tdD2 DECIMAL(15,5);
tdU2 DECIMAL(15,5);
tklas_id NUMBER;
klas1_find NUMBER;
klas2_find NUMBER;
tdelta_ref1 DECIMAL(15,5);
tdelta_ref2 DECIMAL(15,5);
tdelta_ref1_org DECIMAL(15,5);
tdelta_ref2_org DECIMAL(15,5);
tklas_id1 klasy.klas_id%TYPE;
tklas_id2 klasy.klas_id%TYPE;
min1 DECIMAL(15,5);
wartosc_delty DECIMAL(15,5);
rec_klasy klasy_t;
x_RZC1 DECIMAL(15,5);
x_SCRV1 DECIMAL(15,5);
x_TR1 DECIMAL(15,5);
x_JRZC1 DECIMAL(15,5);
x_RZC2 DECIMAL(15,5);
x_SCRV2 DECIMAL(15,5);
x_TR2 DECIMAL(15,5);
x_JRZC2 DECIMAL(15,5);

delta1 DECIMAL(15,5);
delta2 DECIMAL(15,5);

CURSOR cs_spread IS
SELECT span_klasy_spready.*,n.spn_klas_id as klA,s.spn_klas_id as klB,n.spn_liczba_delt as ldA,s.spn_liczba_delt as ldB,n.spn_nr_poziomu as nrpA,s.spn_nr_poziomu as nrpB
FROM span_klasy_spready,spready_nogi n,spready_nogi s
WHERE n.spn_spks_id=span_klasy_spready.spks_id AND s.spn_spks_id=span_klasy_spready.spks_id
AND n.spn_strona='A' AND s.spn_strona='B' AND span_klasy_spready.spks_typ = 'Z' AND n.spn_klas_id in (select zlc_klas_id from zlecenia)
ORDER BY span_klasy_spready.spks_priorytet;

CURSOR cs_scen (p_id_klasy NUMBER) IS
SELECT b.* FROM (
      SELECT (CASE
  WHEN (a.scen_numer > 15) THEN a.wartosc
  WHEN (mod(a.scen_numer,2)) <> 0 THEN (select (b.wartosc+a.wartosc)/2 from mv_klasy b where b.sppa_klas_id=a.sppa_klas_id and b.scen_numer = a.scen_numer+1)
  ELSE (select (b.wartosc+a.wartosc)/2 from mv_klasy b where b.sppa_klas_id=a.sppa_klas_id and b.scen_numer = a.scen_numer -1)
END) as SCRV1 FROM mv_klasy a WHERE a.maximum=a.wartosc AND a.sppa_klas_id = p_id_klasy) b WHERE b.SCRV1 <> 0;

CURSOR cs_klasy (p_id_klasy NUMBER) IS
SELECT klas_id, sum(DECODE(zlc_typ_operacji,'S',-1*zlc_ilosc*sppa_wsp_skal_delty*sppa_delta,'K',zlc_ilosc*sppa_wsp_skal_delty*sppa_delta,0)) as iloscD
FROM zlecenia,klasy,span_papiery WHERE zlc_klas_id=klas_id AND sppa_klas_id=zlc_klas_id AND sppa_id=zlc_sppa_id
AND klas_id = p_id_klasy group by klas_id;

CURSOR cs_klasy_1 (p_id_klasy NUMBER) IS
select (scen1 + scen2)/2 as TR1 from (
SELECT scen_numer as scen1,0 as scen2 FROM mv_klasy WHERE scen_numer = 1  AND sppa_klas_id = p_id_klasy
UNION ALL
SELECT 0 as scen1,scen_numer as scen2 FROM mv_klasy WHERE scen_numer = 2  AND sppa_klas_id = p_id_klasy
);
begin
i :=1;
i1 :=0;
i2 :=0;
suma := 0;
FOR r_spread IN cs_spread LOOP
  i1 := i;
  i2 := i+1;
  klas1_find := 0;
  klas2_find := 0;
  tdelta_ref1_org := 0;
  tdelta_ref2_org := 0;

  OPEN cs_klasy(r_spread.klA);
  FETCH cs_klasy INTO tklas_id1,tdelta_ref1_org;
  CLOSE cs_klasy;

  OPEN cs_klasy(r_spread.klB);
  FETCH cs_klasy INTO tklas_id2,tdelta_ref2_org;
  CLOSE cs_klasy;
begin

   FOR inx1 IN 1..rec_klasy.count LOOP
    IF rec_klasy(inx1).klas_id = r_spread.klA THEN
     i1 := inx1;
     tdelta_ref1 := rec_klasy(inx1).tdD;
	 klas1_find := 1;
    END IF;
    IF rec_klasy(inx1).klas_id = r_spread.klB  THEN
     i2 := inx1;
     tdelta_ref2 := rec_klasy(inx1).tdD;
	 klas2_find := 1;
    END IF;
  END LOOP;
EXCEPTION
 WHEN NO_DATA_FOUND THEN
  NULL;
	 END;
  IF klas1_find = 0 THEN
	tdelta_ref1 := tdelta_ref1_org;
  END IF;
  IF klas2_find = 0 THEN
	tdelta_ref2 := tdelta_ref2_org;
  END IF;
  IF ((tdelta_ref1 < 0 AND tdelta_ref2 < 0) OR (tdelta_ref1 > 0 AND tdelta_ref2 > 0) OR tdelta_ref2 = 0 OR tdelta_ref1 = 0 ) THEN
	CONTINUE;
  END IF;
  OPEN cs_scen(tklas_id1);
  FETCH cs_scen INTO x_SCRV1;
  CLOSE cs_scen;

  OPEN cs_scen(tklas_id2);
  FETCH cs_scen INTO x_SCRV2;
  CLOSE cs_scen;


	select (sum(scen1) + sum(scen2))/2 as TR1 INTO x_TR1 from (
	SELECT wartosc as scen1,0 as scen2  FROM mv_klasy WHERE scen_numer = 1  AND sppa_klas_id = tklas_id1
	UNION ALL
	SELECT 0 as scen1,wartosc as scen2  FROM mv_klasy WHERE scen_numer = 2  AND sppa_klas_id = tklas_id1
	);

	select (sum(scen1) + sum(scen2))/2 as TR2 INTO x_TR2 from (
	SELECT wartosc as scen1,0 as scen2  FROM mv_klasy WHERE scen_numer = 1  AND sppa_klas_id = tklas_id2
	UNION ALL
	SELECT 0 as scen1,wartosc as scen2  FROM mv_klasy WHERE scen_numer = 2  AND sppa_klas_id = tklas_id2
	);
    x_RZC1 := x_SCRV1 - x_TR1;
    x_RZC2 := x_SCRV2 - x_TR2;

	x_JRZC1 := x_RZC1/ABS(tdelta_ref1_org);
	x_JRZC2 := x_RZC2/ABS(tdelta_ref2_org);

   IF x_JRZC2 < 0 OR x_JRZC2 <0 THEN
     CONTINUE;
   END IF;
  IF (tdelta_ref1/r_spread.ldA > 0) THEN
    IF (tdelta_ref2/r_spread.ldB < 0) THEN
      min1 := LEAST(ABS(tdelta_ref2/r_spread.ldB),ABS(tdelta_ref1/r_spread.ldA));
      tdelta_ref1 := tdelta_ref1 - min1*r_spread.ldA;
      tdelta_ref2 := tdelta_ref2 + min1*r_spread.ldB;
      wartosc_delty := min1*r_spread.spks_depozyt;
    END IF;
  ELSIF (tdelta_ref2/r_spread.ldB > 0) THEN
      min1 := LEAST(ABS(tdelta_ref2/r_spread.ldB),ABS(tdelta_ref1/r_spread.ldA));
      tdelta_ref1 := tdelta_ref1 + min1*r_spread.ldA;
      tdelta_ref2 := tdelta_ref2 - min1*r_spread.ldB;
      wartosc_delty := min1*r_spread.spks_depozyt;
  END IF;

   delta1 := x_JRZC1 * wartosc_delty * r_spread.ldA;
   delta2 := x_JRZC2 * wartosc_delty * r_spread.ldB;

  IF klas1_find = 0 THEN
    i := i+1;
  END IF;
  IF klas2_find = 0 THEN
    i := i+1;
  END IF;
  rec_klasy(i1).klas_id := tklas_id1;
  rec_klasy(i1).nr_poziomu := 0;
  rec_klasy(i1).tdD := tdelta_ref1;
  rec_klasy(i1).wartosc := nvl(rec_klasy(i1).wartosc,0) + delta1;

  rec_klasy(i2).klas_id := tklas_id2;
  rec_klasy(i2).nr_poziomu := 0;
  rec_klasy(i2).tdD := tdelta_ref2;
  rec_klasy(i2).wartosc := nvl(rec_klasy(i2).wartosc,0) + delta2;

END LOOP;
suma := 0;


FOR inx1 IN 1..rec_klasy.count LOOP
begin
  suma := suma + round(nvl(rec_klasy(inx1).wartosc,0));
  EXCEPTION
 WHEN NO_DATA_FOUND THEN
  NULL;
	 END;
END LOOP;

return suma;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         new_status := 'brak spreadow';
      WHEN OTHERS THEN
         new_status := 'fnOblInter: '||SUBSTR(SQLERRM,1,70);
end oblInter;

FUNCTION oblIntra
   RETURN decimal IS
suma decimal(15,2);
i NUMBER;
i1 NUMBER;
i2 NUMBER;
tdD zlecenia.zlc_ilosc%TYPE;
tdU zlecenia.zlc_ilosc%TYPE;
tdD1 zlecenia.zlc_ilosc%TYPE;
tdU1 zlecenia.zlc_ilosc%TYPE;
tdD2 zlecenia.zlc_ilosc%TYPE;
tdU2 zlecenia.zlc_ilosc%TYPE;
tnr_poziomu1 span_papiery.sppa_nr_poziomu%TYPE;
tnr_poziomu2 span_papiery.sppa_nr_poziomu%TYPE;
tklas_id klasy.klas_id%TYPE;
min1 DECIMAL(15,2);
wartosc_delty DECIMAL(15,2);
rec_klasy klasy_t;

CURSOR cs_spread  IS
SELECT span_klasy_spready.*,n.spn_klas_id as klA,s.spn_klas_id as klB,n.spn_liczba_delt as ldA,s.spn_liczba_delt as ldB,n.spn_nr_poziomu as nr_poziomuA,
s.spn_nr_poziomu as nr_poziomuB
FROM span_klasy_spready,spready_nogi n,spready_nogi s
WHERE n.spn_spks_id=span_klasy_spready.spks_id AND s.spn_spks_id=span_klasy_spready.spks_id
AND n.spn_strona='A' AND s.spn_strona='B' AND span_klasy_spready.spks_typ = 'W' AND n.spn_klas_id in (select zlc_klas_id from zlecenia)
ORDER BY span_klasy_spready.spks_priorytet;

CURSOR cs_klasy (p_id_klasy NUMBER,p_nr_poziomu NUMBER) IS
select klas_id,sum(iloscD) as dD, sum(iloscU) as dU, sppa_nr_poziomu FROM (
SELECT klas_id, DECODE(zlc_typ_operacji,'S',0,'K',zlc_ilosc*sppa_wsp_skal_delty*sppa_delta,0) as iloscD, DECODE(zlc_typ_operacji,'S',zlc_ilosc*sppa_wsp_skal_delty*sppa_delta,0) as iloscU, sppa_nr_poziomu
FROM zlecenia,klasy,span_papiery WHERE zlc_klas_id=klas_id AND sppa_klas_id=zlc_klas_id AND sppa_id=zlc_sppa_id
AND klas_id = p_id_klasy
AND sppa_nr_poziomu = p_nr_poziomu ) group by klas_id,sppa_nr_poziomu;
begin

i :=1;
i1 :=0;
i2 :=0;
suma := 0;
FOR r_spread IN cs_spread LOOP
  i1 := i;
  i2 := i+1;
  tdD1 := 0;
  tdU1 := 0;
  tdD2 := 0;
  tdU2 := 0;
  tnr_poziomu1 := 0;
  tnr_poziomu2 := 0;
  OPEN cs_klasy(r_spread.klA,r_spread.nr_poziomuA);
  FETCH cs_klasy INTO tklas_id,tdD1,tdU1,tnr_poziomu1;
  CLOSE cs_klasy;

  OPEN cs_klasy(r_spread.klB,r_spread.nr_poziomuB);
  FETCH cs_klasy INTO tklas_id,tdD2,tdU2,tnr_poziomu2;
  CLOSE cs_klasy;


  BEGIN
  FOR inx1 IN 1..rec_klasy.count LOOP
    IF rec_klasy(inx1).klas_id = r_spread.klA AND rec_klasy(inx1).nr_poziomu = r_spread.nr_poziomuA THEN
     tdD1 := rec_klasy(inx1).tdD;
     tdU1 := rec_klasy(inx1).tdU;
	 i1 := inx1;
    END IF;
    IF rec_klasy(inx1).klas_id = r_spread.klB AND rec_klasy(inx1).nr_poziomu = r_spread.nr_poziomuB  THEN
     tdD2 := rec_klasy(inx1).tdD;
     tdU2 := rec_klasy(inx1).tdU;
	 i2 := inx1;
    END IF;

  END LOOP;
EXCEPTION
 WHEN NO_DATA_FOUND THEN
  NULL;
END;

  IF (tdD1 < tdD2) THEN
    tdD := tdD2;
    tdU := tdU1;
    IF (tdD2/r_spread.ldA > tdU1/r_spread.ldB) THEN
      min1 := tdU1/r_spread.ldB;
      tdD2 := tdD2/r_spread.ldA - min1;
	  tdU1 := 0;
      wartosc_delty := min1*r_spread.spks_depozyt;
    ELSE
      min1 := tdD2/r_spread.ldA;
      tdU1 := tdU1/r_spread.ldB - min1;
	  tdD2 := 0;
      wartosc_delty := min1*r_spread.spks_depozyt;
    END IF;
  ELSE
    tdD := tdD1;
    tdU := tdU2;
    IF (tdD1/r_spread.ldA > tdU2/r_spread.ldB) THEN
      min1 := tdU2/r_spread.ldB;
      tdD1 := tdD1/r_spread.ldA - min1;
	  tdU2 := 0;
      wartosc_delty := min1*r_spread.spks_depozyt;
    ELSE
      min1 := tdD1/r_spread.ldA;
      tdU2 := tdU2/r_spread.ldB - min1;
	  tdD1 := 0;
      wartosc_delty := min1*r_spread.spks_depozyt;
    END IF;
	IF tnr_poziomu2 = tnr_poziomu1 THEN /*taka sama klasa i poziom */
		tdD2 := tdD1;
		tdU1 := tdU2;
	END IF;
  END IF;
  IF (wartosc_delty<0) THEN
	wartosc_delty := 0;
  END IF;

  rec_klasy(i1).klas_id := tklas_id;
  rec_klasy(i1).nr_poziomu := tnr_poziomu1;
  rec_klasy(i1).tdD := tdD1;
  rec_klasy(i1).tdU := tdU1;
  rec_klasy(i1).wartosc := wartosc_delty;
  i := i + 1;
  if (tnr_poziomu2 <> tnr_poziomu1) THEN
	  rec_klasy(i2).klas_id := tklas_id;
	  rec_klasy(i2).nr_poziomu := tnr_poziomu2;
	  rec_klasy(i2).tdD := tdD2;
	  rec_klasy(i2).tdU := tdU2;
	  rec_klasy(i2).wartosc := wartosc_delty;
	  i := i + 1;
  END IF;
  suma := suma + nvl(round(wartosc_delty),0);
END LOOP;

return suma;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
         new_status := 'Brak Spreadow Wewnatrzklasowych';
		 return suma;
      WHEN OTHERS THEN
         new_status := 'fnOblIntra: '||SUBSTR(SQLERRM,1,70);
		 return suma;
end oblIntra;

FUNCTION fnPNO
	return number is
	v_PNO decimal (15,2);
CURSOR cs_klas IS
select sppa_klas_id,NVL(sum(DECODE(zlc_typ_operacji,'K',zlc_ilosc,(-1)*zlc_ilosc)*round(sppa_cena_instr*sppa_mnoznik,2)),0) as ilosc from zlecenia,span_papiery where sppa_id=zlc_sppa_id and sppa_typ_papieru='EQTY' group by sppa_klas_id;

begin
v_PNO := 0;
FOR k IN cs_klas LOOP
v_PNO := v_PNO + k.ilosc;
END LOOP;
return v_PNO;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         new_status := 'brak PNO';
		 RETURN 0;
      WHEN OTHERS THEN
         new_status := 'fnPNO: '||SUBSTR(SQLERRM,1,70);
end fnPNO;

FUNCTION fnPO
	return number is
	v_PO decimal (15,2);
CURSOR cs_klas IS
select sppa_klas_id,NVL(sum(DECODE(zlc_typ_operacji,'K',zlc_ilosc,(-1)*zlc_ilosc)*round(zlc_cena_jedn*sppa_mnoznik,2)),0) as ilosc from zlecenia,span_papiery where sppa_id=zlc_sppa_id and sppa_typ_papieru='EQTY' group by sppa_klas_id;

begin
v_PO := 0;
FOR k IN cs_klas LOOP
v_PO := v_PO + k.ilosc;
END LOOP;
return v_PO;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         new_status := 'brak PO';
		 RETURN 0;
      WHEN OTHERS THEN
         new_status := 'fnPO: '||SUBSTR(SQLERRM,1,70);
end fnPO;

FUNCTION fnMDKO
	return number is
	v_MDKO decimal (15,2) ;
CURSOR cs_klas IS
select sppa_klas_id,NVL(sum(zlc_ilosc*round(sppa_cena_instr*klas_som,2)),0) as ilosc from zlecenia,span_papiery,klasy where sppa_id=zlc_sppa_id and sppa_typ_papieru='EQTY' and zlc_typ_operacji='S' and sppa_klas_id=klas_id group by sppa_klas_id;

begin
v_MDKO := 0;
FOR k IN cs_klas
LOOP

v_MDKO := v_MDKO + k.ilosc;

END LOOP;
return v_MDKO;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         new_status := 'brak mdko';
		 RETURN 0;
      WHEN OTHERS THEN
         new_status := 'fnMDKO: '||SUBSTR(SQLERRM,1,70);
end fnMDKO;


PROCEDURE prOblDep (	p_depozyt OUT NUMBER,
	p_NOD  OUT NUMBER,
	p_PNO  OUT NUMBER,
	p_PO  OUT NUMBER)
IS
suma decimal(15,2);
mdko decimal(15,2);
v_ryzyko  decimal(15,2);
szew  decimal(15,2);
swew decimal(15,2);
DPNO decimal(15,2);
begin
szew := pk_span.oblInter;
swew := pk_span.oblIntra;
mdko := pk_span.fnMDKO;
p_pno := pk_span.fnPNO;
p_PO := pk_span.fnPO;
select sum(maximum) INTO v_ryzyko from (
SELECT distinct maximum,sppa_klas_id FROM mv_klasy );
DPNO := GREATEST(ROUND(GREATEST(v_ryzyko + swew,mdko) - szew) - p_pno,0);
p_NOD := GREATEST(p_pno - ROUND(GREATEST(v_ryzyko + swew,mdko) - szew),0);
p_depozyt := DPNO - p_NOD;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
	 new_status := 'brak spreadow';
  WHEN OTHERS THEN
	 new_status := 'prOblDep: '||SUBSTR(SQLERRM,1,70);
end prOblDep;

PROCEDURE prDodajPozycje(p_symbol VARCHAR2,p_ilosc NUMBER, p_cena_jedn DECIMAL) IS
begin
INSERT INTO zlecenia (zlc_id,zlc_klas_id,zlc_ilosc,zlc_cena_jedn,zlc_typ_operacji,zlc_sppa_id)
(select zlc_seq.nextval,sppa_klas_id,ABS(p_ilosc),p_cena_jedn,(CASE SIGN(p_ilosc) WHEN -1 THEN 'S' ELSE 'K' END),sppa_id
from span_papiery WHERE sppa_nazwa=p_symbol);

DBMS_MVIEW.REFRESH(LIST=>'MV_KLASY');
EXCEPTION
  WHEN OTHERS THEN
	 new_status := 'prDodajPozycje: '||SUBSTR(SQLERRM,1,70);
end prDodajPozycje;

PROCEDURE prCzysc IS
begin
DELETE FROM zlecenia;
EXCEPTION
  WHEN OTHERS THEN
	 new_status := 'prCzysc: '||SUBSTR(SQLERRM,1,70);
end prCzysc;

PROCEDURE prTest IS
depozyt DECIMAL(15,2);
v_NOD  NUMBER(15,2);
v_PNO  NUMBER(15,2);
v_PO  NUMBER(15,2);
begin
dbms_output.put_line('Wartosci porownawcze wg importu pliku RPJNE_ZRS.xml z dnia 20141031');
/* pierwszy test Spready Zewnatrzklasowe Kontrakty */
pk_span.prCzysc();
pk_span.prDodajPozycje('FW20Z1420',5,4.5);
pk_span.prDodajPozycje('FW40H15',-8,4.5);
pk_span.prDodajPozycje('F3MWZ14',-4,4.5);
pk_span.prDodajPozycje('F6MWZ14',6,4.5);
pk_span.prDodajPozycje('F1MWZ14',-10,4.5);
pk_span.prOblDep(depozyt,v_NOD,v_PNO,v_PO);
dbms_output.put_line('Kalkulator : '||depozyt||' -> KDPW_CCP : 33094');
/* drugi test Spready Zewnatrzklasowe Kontrakty z wieloma priorytetami*/
pk_span.prCzysc();
pk_span.prDodajPozycje('FW20Z1420',5,4.5);
pk_span.prDodajPozycje('FW40H15',-8,4.5);
pk_span.prDodajPozycje('F3MWZ14',-4,4.5);
pk_span.prDodajPozycje('F6MWZ14',6,4.5);
pk_span.prOblDep(depozyt,v_NOD,v_PNO,v_PO);
dbms_output.put_line('Kalkulator : '||depozyt||' -> KDPW_CCP : 28864');
/* trzeci test Spready Zewnatrzklasowe Opcje z Kontraktami*/
pk_span.prCzysc();
pk_span.prDodajPozycje('OW20L142600',10,4.5);
pk_span.prDodajPozycje('OW20X142650',-6,4.5);
pk_span.prDodajPozycje('FW40H15',-8,4.5);
pk_span.prOblDep(depozyt,v_NOD,v_PNO,v_PO);
dbms_output.put_line('Kalkulator : '||depozyt||' -> KDPW_CCP : 20707.30');

/*czwarty test Spready Wewnatrzklasowe Kontrakty*/
pk_span.prCzysc();
pk_span.prDodajPozycje('F3MWH15',8,4.5);
pk_span.prDodajPozycje('F3MWJ15',-2,4.5);
pk_span.prDodajPozycje('F3MWN15',-3,4.5);
pk_span.prDodajPozycje('F3MWU15',6,4.5);
pk_span.prDodajPozycje('F3MWM16',6,4.5);
pk_span.prDodajPozycje('F3MWH16',-5,4.5);
pk_span.prOblDep(depozyt,v_NOD,v_PNO,v_PO);
dbms_output.put_line('Kalkulator : '||depozyt||' -> KDPW_CCP : 17909');

/*piaty test Spready Wewnatrzklasowe Kontrakty na W20*/
pk_span.prCzysc();
pk_span.prDodajPozycje('FW20Z1420',8,4.5);
pk_span.prDodajPozycje('FW20U1520',-2,4.5);
pk_span.prOblDep(depozyt,v_NOD,v_PNO,v_PO);
dbms_output.put_line('Kalkulator : '||depozyt||' -> KDPW_CCP : 24860');

/*szosty test Spready Wewnatrzklasowe Opcje na W20*/
pk_span.prCzysc();
pk_span.prDodajPozycje('OW20O152900',-2,4.5);
pk_span.prDodajPozycje('OW20F152000',8,4.5);
pk_span.prOblDep(depozyt,v_NOD,v_PNO,v_PO);
dbms_output.put_line('Kalkulator : '||depozyt||' -> KDPW_CCP : -10971.82');
EXCEPTION
  WHEN OTHERS THEN
	 new_status := 'prTest: '||SUBSTR(SQLERRM,1,70);
end prTest;
END pk_span;
/
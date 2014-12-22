/* SPAN margin Import PL/SQL Package  
   Author: ESM Technology Karol Przybylski
   Date: 2014-12-01
   Visit http://www.esm-technology.pl or http://github.com/itorK
*/
CREATE OR Replace package pk_import Is
PROCEDURE prDodajPapier(
	v_sppa_nazwa IN varchar2,
	v_nazwa_klasy IN VARCHAR2,
	v_data_wyg  IN VARCHAR2,
	v_kurs_instr  IN DECIMAL,
	v_typ_papieru  IN VARCHAR2,
	v_czas_do_wygas  IN DECIMAL,
	v_psr IN DECIMAL,
	v_ryz_zmien  IN DECIMAL,
	v_mnoznik  IN DECIMAL,
	v_delta_ref  IN DECIMAL,
	v_stopa_proc IN  DECIMAL,
	v_wsp_skal  IN DECIMAL,
	v_cena_instr  IN DECIMAL,
    v_scen1 IN DECIMAL,
	v_scen2 IN DECIMAL,
	v_scen3 IN DECIMAL,
	v_scen4 IN DECIMAL,
	v_scen5 IN DECIMAL,
	v_scen6 IN DECIMAL,
	v_scen7 IN DECIMAL,
	v_scen8 IN DECIMAL,
	v_scen9 IN DECIMAL,
	v_scen10 IN DECIMAL,
	v_scen11 IN DECIMAL,
	v_scen12 IN DECIMAL,
	v_scen13 IN DECIMAL,
	v_scen14 IN DECIMAL,
	v_scen15 IN DECIMAL,
	v_scen16 IN DECIMAL,
	v_kod_span IN VARCHAR2	);
PROCEDURE prDodajPapierO(
	v_sppa_nazwa IN varchar2,
	v_nazwa_klasy IN VARCHAR2,
	v_data_wyg  IN VARCHAR2,
	v_kurs_instr  IN DECIMAL,
	v_typ_papieru  IN VARCHAR2,
	v_czas_do_wygas  IN DECIMAL,
	v_psr IN DECIMAL,
	v_ryz_zmien  IN DECIMAL,
	v_mnoznik  IN DECIMAL,
	v_delta_ref  IN DECIMAL,
	v_stopa_proc IN  DECIMAL,
	v_wsp_skal  IN DECIMAL,
	v_cena_instr  IN DECIMAL,
    v_scen1 IN DECIMAL,
	v_scen2 IN DECIMAL,
	v_scen3 IN DECIMAL,
	v_scen4 IN DECIMAL,
	v_scen5 IN DECIMAL,
	v_scen6 IN DECIMAL,
	v_scen7 IN DECIMAL,
	v_scen8 IN DECIMAL,
	v_scen9 IN DECIMAL,
	v_scen10 IN DECIMAL,
	v_scen11 IN DECIMAL,
	v_scen12 IN DECIMAL,
	v_scen13 IN DECIMAL,
	v_scen14 IN DECIMAL,
	v_scen15 IN DECIMAL,
	v_scen16 IN DECIMAL,
	v_kod_span IN VARCHAR2,
	v_zmien_op_wygasl IN DECIMAL,
	v_stopa_dyw IN DECIMAL,
	v_kurs_wyk IN DECIMAL,
	v_rodzaj_opcji IN VARCHAR2,
	v_zmien_op IN DECIMAL,
    v_cena_baz IN DECIMAL	);
PROCEDURE prDodajSpread(
    p_spks_typ IN VARCHAR2,
	p_spks_depozyt IN DECIMAL,
	p_spks_priorytet IN NUMBER,
    p_nazwa_klasy IN VARCHAR2,
	p_spn_nr_poziomu IN NUMBER,
	p_spn_strona IN VARCHAR2,
	p_spn_liczba_delt IN DECIMAL	);

	PROCEDURE prCzysc;
	FUNCTION dajStatus
   RETURN varchar2;
END pk_import;
/

CREATE OR Replace package body pk_import Is
new_status  VARCHAR2(70) := 'OK';
PROCEDURE prCzysc IS
begin
	DELETE scenariusze;
	DELETE span_papiery;
	DELETE klasy;
	DELETE span_klasy_spready;
	DELETE spready_nogi;
EXCEPTION
  WHEN OTHERS THEN
	 new_status := 'prCzysc: '||SUBSTR(SQLERRM,1,70);
	 raise_application_error(-20001,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);
end prCzysc;

PROCEDURE prDodajPapier(
	v_sppa_nazwa IN varchar2,
	v_nazwa_klasy IN VARCHAR2,
	v_data_wyg  IN VARCHAR2,
	v_kurs_instr  IN DECIMAL,
	v_typ_papieru  IN VARCHAR2,
	v_czas_do_wygas  IN DECIMAL,
	v_psr IN DECIMAL,
	v_ryz_zmien  IN DECIMAL,
	v_mnoznik  IN DECIMAL,
	v_delta_ref  IN DECIMAL,
	v_stopa_proc IN  DECIMAL,
	v_wsp_skal  IN DECIMAL,
	v_cena_instr  IN DECIMAL,
    v_scen1 IN DECIMAL,
	v_scen2 IN DECIMAL,
	v_scen3 IN DECIMAL,
	v_scen4 IN DECIMAL,
	v_scen5 IN DECIMAL,
	v_scen6 IN DECIMAL,
	v_scen7 IN DECIMAL,
	v_scen8 IN DECIMAL,
	v_scen9 IN DECIMAL,
	v_scen10 IN DECIMAL,
	v_scen11 IN DECIMAL,
	v_scen12 IN DECIMAL,
	v_scen13 IN DECIMAL,
	v_scen14 IN DECIMAL,
	v_scen15 IN DECIMAL,
	v_scen16 IN DECIMAL,
	v_kod_span IN VARCHAR2) IS
	begin
    pk_import.prDodajPapierO(	v_sppa_nazwa,
	v_nazwa_klasy,
	v_data_wyg,
	v_kurs_instr,
	v_typ_papieru,
	v_czas_do_wygas,
	v_psr,
	v_ryz_zmien,
	v_mnoznik,
	v_delta_ref,
	v_stopa_proc,
	v_wsp_skal,
	v_cena_instr,
    v_scen1,
	v_scen2,
	v_scen3,
	v_scen4,
	v_scen5,
	v_scen6,
	v_scen7,
	v_scen8,
	v_scen9,
	v_scen10,
	v_scen11,
	v_scen12,
	v_scen13,
	v_scen14,
	v_scen15,
	v_scen16,
	v_kod_span,
	null,
	null,
	null,
	null,
	null,
	null);

EXCEPTION
      WHEN OTHERS THEN
         new_status := 'prDodajPapier: '||SUBSTR(SQLERRM,1,70);
		 raise_application_error(-20001,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);
end prDodajPapier;

PROCEDURE prDodajPapierO(
	v_sppa_nazwa IN varchar2,
	v_nazwa_klasy IN VARCHAR2,
	v_data_wyg  IN VARCHAR2,
	v_kurs_instr  IN DECIMAL,
	v_typ_papieru  IN VARCHAR2,
	v_czas_do_wygas  IN DECIMAL,
	v_psr IN DECIMAL,
	v_ryz_zmien  IN DECIMAL,
	v_mnoznik  IN DECIMAL,
	v_delta_ref  IN DECIMAL,
	v_stopa_proc IN  DECIMAL,
	v_wsp_skal  IN DECIMAL,
	v_cena_instr  IN DECIMAL,
    v_scen1 IN DECIMAL,
	v_scen2 IN DECIMAL,
	v_scen3 IN DECIMAL,
	v_scen4 IN DECIMAL,
	v_scen5 IN DECIMAL,
	v_scen6 IN DECIMAL,
	v_scen7 IN DECIMAL,
	v_scen8 IN DECIMAL,
	v_scen9 IN DECIMAL,
	v_scen10 IN DECIMAL,
	v_scen11 IN DECIMAL,
	v_scen12 IN DECIMAL,
	v_scen13 IN DECIMAL,
	v_scen14 IN DECIMAL,
	v_scen15 IN DECIMAL,
	v_scen16 IN DECIMAL,
	v_kod_span IN VARCHAR2,
	v_zmien_op_wygasl IN DECIMAL,
	v_stopa_dyw IN DECIMAL,
	v_kurs_wyk IN DECIMAL,
	v_rodzaj_opcji IN VARCHAR2,
	v_zmien_op IN DECIMAL,
    v_cena_baz IN DECIMAL
	) IS

      CURSOR cu_klasy
      IS
         SELECT klas_id
		  FROM klasy
          WHERE klas_nazwa_span = v_kod_span;
v_found                       BOOLEAN;
v_klas_id                    klasy.klas_id%TYPE;
begin

      OPEN cu_klasy;

      FETCH cu_klasy
       INTO v_klas_id;
      v_found := cu_klasy%FOUND;

      CLOSE cu_klasy;
      IF NOT v_found THEN
         INSERT INTO klasy(klas_id,klas_nazwa,klas_som,klas_nazwa_span) values (klas_seq.nextval, v_nazwa_klasy, 0, v_kod_span) RETURNING klas_id INTO v_klas_id;
      END IF;

INSERT INTO span_papiery
			(sppa_id,sppa_nazwa,sppa_klas_id,sppa_data_wygas,sppa_typ_papieru,sppa_czas_do_wygas,sppa_psr,
				sppa_vsr,sppa_mnoznik,sppa_delta,sppa_stopa_proc,sppa_wsp_skal_delty,sppa_cena_instr,sppa_nr_poziomu,sppa_zmien_op_wygasl,sppa_stopa_dyw,sppa_kurs_wyk,sppa_rodzaj_opcji,sppa_zmien_op, sppa_cena_instr_baz)
				values (sppa_seq.nextval,v_sppa_nazwa, v_klas_id, TO_DATE(v_data_wyg,'YYYYMM'),v_typ_papieru,v_czas_do_wygas , v_psr ,
				v_ryz_zmien,v_mnoznik,v_delta_ref,v_stopa_proc, v_wsp_skal,v_kurs_instr, 99,v_zmien_op_wygasl,v_stopa_dyw,v_kurs_wyk,v_rodzaj_opcji,v_zmien_op, v_cena_baz);

	INSERT INTO scenariusze (scen_id,scen_sppa_id,scen_numer,scen_wartosc)
	 values (scen_seq.nextval,sppa_seq.currval, 1,v_scen1);
	 	INSERT INTO scenariusze (scen_id,scen_sppa_id,scen_numer,scen_wartosc)
	 values (scen_seq.nextval,sppa_seq.currval, 2,v_scen2);
	 	INSERT INTO scenariusze (scen_id,scen_sppa_id,scen_numer,scen_wartosc)
	 values (scen_seq.nextval,sppa_seq.currval, 3,v_scen3);
	 	INSERT INTO scenariusze (scen_id,scen_sppa_id,scen_numer,scen_wartosc)
	 values (scen_seq.nextval,sppa_seq.currval, 4,v_scen4);
	 	INSERT INTO scenariusze (scen_id,scen_sppa_id,scen_numer,scen_wartosc)
	 values (scen_seq.nextval,sppa_seq.currval, 5,v_scen5);
	 	INSERT INTO scenariusze (scen_id,scen_sppa_id,scen_numer,scen_wartosc)
	 values (scen_seq.nextval,sppa_seq.currval, 6,v_scen6);
	 	INSERT INTO scenariusze (scen_id,scen_sppa_id,scen_numer,scen_wartosc)
	 values (scen_seq.nextval,sppa_seq.currval, 7,v_scen7);
	 	INSERT INTO scenariusze (scen_id,scen_sppa_id,scen_numer,scen_wartosc)
	 values (scen_seq.nextval,sppa_seq.currval, 8,v_scen8);
	 	INSERT INTO scenariusze (scen_id,scen_sppa_id,scen_numer,scen_wartosc)
	 values (scen_seq.nextval,sppa_seq.currval, 9,v_scen9);
	 	INSERT INTO scenariusze (scen_id,scen_sppa_id,scen_numer,scen_wartosc)
	 values (scen_seq.nextval,sppa_seq.currval, 10,v_scen10);
	 	INSERT INTO scenariusze (scen_id,scen_sppa_id,scen_numer,scen_wartosc)
	 values (scen_seq.nextval,sppa_seq.currval, 11,v_scen11);
	 	INSERT INTO scenariusze (scen_id,scen_sppa_id,scen_numer,scen_wartosc)
	 values (scen_seq.nextval,sppa_seq.currval, 12,v_scen12);
	 	INSERT INTO scenariusze (scen_id,scen_sppa_id,scen_numer,scen_wartosc)
	 values (scen_seq.nextval,sppa_seq.currval, 13,v_scen13);
	 	INSERT INTO scenariusze (scen_id,scen_sppa_id,scen_numer,scen_wartosc)
	 values (scen_seq.nextval,sppa_seq.currval, 14,v_scen14);
	 	INSERT INTO scenariusze (scen_id,scen_sppa_id,scen_numer,scen_wartosc)
	 values (scen_seq.nextval,sppa_seq.currval, 15,v_scen15);
	 	INSERT INTO scenariusze (scen_id,scen_sppa_id,scen_numer,scen_wartosc)
	 values (scen_seq.nextval,sppa_seq.currval, 16,v_scen16);
commit;
   EXCEPTION
      WHEN OTHERS THEN
         new_status := 'prDodajPapierO: '||SUBSTR(SQLERRM,1,70);
		 raise_application_error(-20001,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);
end prDodajPapierO;

PROCEDURE prDodajSpread(
    p_spks_typ IN VARCHAR2,
	p_spks_depozyt IN DECIMAL,
	p_spks_priorytet IN NUMBER,
    p_nazwa_klasy IN VARCHAR2,
	p_spn_nr_poziomu IN NUMBER,
	p_spn_strona IN VARCHAR2,
	p_spn_liczba_delt IN DECIMAL	) IS

CURSOR cu_klasy
IS
 SELECT klas_id
  FROM klasy
  WHERE nvl(substr(klas_nazwa_span,1,INSTR(klas_nazwa_span,'/')-1),klas_nazwa_span) = p_nazwa_klasy;

CURSOR cu_spready
IS
 SELECT spks_id
  FROM span_klasy_spready
  WHERE spks_typ = p_spks_typ
  AND spks_depozyt = p_spks_depozyt
  AND spks_priorytet = p_spks_priorytet;


v_found                       BOOLEAN;
v_spks_id                     span_klasy_spready.spks_id%TYPE;
v_klas_id                    klasy.klas_id%TYPE;

  begin
        OPEN cu_klasy;

      FETCH cu_klasy
       INTO v_klas_id;
      v_found := cu_klasy%FOUND;
        CLOSE cu_klasy;
      IF NOT v_found THEN
         INSERT INTO klasy(klas_id,klas_nazwa,klas_som,klas_nazwa_span) values (klas_seq.nextval, p_nazwa_klasy, 0, p_nazwa_klasy) RETURNING klas_id INTO v_klas_id;
      END IF;

	        OPEN cu_spready;

      FETCH cu_spready
       INTO v_spks_id;
      v_found := cu_spready%FOUND;
        CLOSE cu_spready;
      IF NOT v_found THEN
	         INSERT INTO span_klasy_spready (spks_id,spks_typ,spks_depozyt,spks_priorytet )
			 VALUES (spks_seq.nextval,p_spks_typ, p_spks_depozyt,p_spks_priorytet)
            RETURNING spks_id INTO v_spks_id;
      END IF;



	        INSERT INTO spready_nogi(spn_id,spn_spks_id , spn_klas_id, spn_nr_poziomu,spn_strona,spn_liczba_delt)
						VALUES (spn_seq.nextval, v_spks_id, v_klas_id,p_spn_nr_poziomu, p_spn_strona, p_spn_liczba_delt);
   EXCEPTION
      WHEN OTHERS THEN
		 new_status := 'prDodajSpread: '||SUBSTR(SQLERRM,1,70);
		 raise_application_error(-20001,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);
end prDodajSpread;

FUNCTION dajStatus
   RETURN varchar2 IS
begin
return new_status;
end dajStatus;
END pk_import;
/

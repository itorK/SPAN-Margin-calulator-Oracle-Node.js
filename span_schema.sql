CREATE TABLESPACE tbs_perm_01
  DATAFILE 'tbs_perm_01.dat'
    SIZE 20M
  ONLINE;

CREATE TEMPORARY TABLESPACE tbs_temp_01
  TEMPFILE 'tbs_temp_01.dbf'
    SIZE 5M
    AUTOEXTEND ON;

CREATE USER span
  IDENTIFIED BY span
    DEFAULT TABLESPACE tbs_perm_01
  TEMPORARY TABLESPACE tbs_temp_01
  QUOTA 20M on tbs_perm_01;

GRANT create session TO span;
GRANT create table TO span;
GRANT create view TO span;
GRANT create any trigger TO span;
GRANT create any procedure TO span;
GRANT create sequence TO span;
GRANT create synonym TO span;

ALTER SESSION SET CURRENT_SCHEMA=span;

CREATE TABLE spready_nogi
    ( spn_id   NUMBER(6)  DEFAULT 0
	 CONSTRAINT    spn_id_nn  NOT NULL
   , spn_spks_id   NUMBER(6)
    , spn_klas_id    NUMBER(6)
	CONSTRAINT    spn_kod_klasy_nn  NOT NULL
    , spn_nr_poziomu NUMBER(6) DEFAULT 0
	CONSTRAINT    spn_nr_poziomu_nn  NOT NULL
    , spn_strona    VARCHAR2(2)
    , spn_liczba_delt DECIMAL(15,6)
    ) ;

CREATE SEQUENCE spn_seq;

ALTER TABLE spready_nogi ADD (
  CONSTRAINT spn_pk PRIMARY KEY (spn_id));

 CREATE TABLE span_klasy_spready
    ( spks_id   NUMBER(6) DEFAULT 0
	 CONSTRAINT    spks_id_nn  NOT NULL
    , spks_typ  VARCHAR2(2)
	CONSTRAINT    spks_typ_nn  NOT NULL
    , spks_priorytet    NUMBER DEFAULT 0
    , spks_depozyt     DECIMAL(16,6) DEFAULT 0
    , spks_wsp_korekty DECIMAL(3,2) DEFAULT 0
    , spks_som         DECIMAL (19,6) DEFAULT 0
    ) ;

ALTER TABLE span_klasy_spready ADD (
  CONSTRAINT spks_pk PRIMARY KEY (spks_id));

CREATE SEQUENCE spks_seq;

 CREATE TABLE span_papiery
 ( sppa_id NUMBER(6),
 sppa_nazwa VARCHAR2(255),
   sppa_pap_id NUMBER(6),
   sppa_klas_id  NUMBER(6)
   	CONSTRAINT   sppa_kod_klasy_nn  NOT NULL,
    sppa_data_wygas DATE,
	sppa_data_gen TIMESTAMP,
    sppa_kurs_wyk decimal(19,4),
    sppa_rodzaj_opcji VARCHAR2(2),
    sppa_typ_papieru VARCHAR2(10),
    sppa_czas_do_wygas decimal(19,6),
    sppa_psr decimal(19,6),
    sppa_vsr decimal(19,6),
    sppa_mnoznik decimal(19,7),
    sppa_delta decimal(10,6),
    sppa_model_wyc varchar2(2),
    sppa_stopa_proc decimal(19,6),
    sppa_zmien_op decimal(19,6),
    sppa_zmien_op_wygasl decimal(19,6),
    sppa_wsp_skal_delty decimal(19,6),
    sppa_stopa_dyw decimal(19,6),
    sppa_nr_poziomu number(6),
    sppa_Intraday varchar2(2),
    sppa_PSR_intra decimal(19,6),
    sppa_godz_waz_intr TIMESTAMP,
    sppa_godz_zamk_intr TIMESTAMP,
    sppa_cena_instr_baz  decimal(19,6),
    sppa_cena_instr decimal(19,6)
 );
ALTER TABLE span_papiery ADD (
  CONSTRAINT sppa_pk PRIMARY KEY (sppa_id));

CREATE SEQUENCE sppa_seq;

CREATE TABLE scenariusze
    ( scen_id   NUMBER(6)  DEFAULT 0
    , scen_sppa_id NUMBER(6)
    , scen_numer NUMBER(6)
    , scen_wartosc NUMBER(15,6)
    ) ;

ALTER TABLE scenariusze ADD (
CONSTRAINT scen_pk PRIMARY KEY (scen_id));

CREATE SEQUENCE scen_seq;


CREATE TABLE zlecenia (
  zlc_id NUMBER(6),
  zlc_klas_id NUMBER(6),
  zlc_ilosc NUMBER(6),
  zlc_cena_jedn decimal(19,6),
  zlc_typ_operacji varchar2(2),
  zlc_sppa_id number(6)
);
ALTER TABLE zlecenia ADD (
  CONSTRAINT zlc_pk PRIMARY KEY (zlc_id));

CREATE SEQUENCE zlc_seq;

CREATE TABLE klasy (
  klas_id NUMBER(6),
  klas_nazwa varchar2(255),
  klas_nazwa_span varchar2(255),
  klas_som decimal(19,6)
);

ALTER TABLE klasy ADD (
  CONSTRAINT klas_pk PRIMARY KEY (klas_id));

CREATE SEQUENCE klas_seq;


CREATE MATERIALIZED VIEW mv_klasy
PARALLEL
BUILD IMMEDIATE AS
select scen_numer,sppa_klas_id,SUM(DECODE(zlc_typ_operacji,'S',-1*zlc_ilosc*scen_wartosc,'K',zlc_ilosc*scen_wartosc,0)) as wartosc,max(SUM(DECODE(zlc_typ_operacji,'S',-1*zlc_ilosc*scen_wartosc,'K',zlc_ilosc*scen_wartosc,0))) over (partition by sppa_klas_id) as maximum
from span_papiery,zlecenia,scenariusze WHERE sppa_id = zlc_sppa_id AND scen_sppa_id=sppa_id
group by sppa_klas_id,scen_numer;
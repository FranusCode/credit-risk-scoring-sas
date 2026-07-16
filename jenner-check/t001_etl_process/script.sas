/* Adapted from etl_process.sas (FranusCode/credit-risk-scoring-sas).
   Upstream reads 7 native SAS tables (bank.loan, bank.client, bank.district,
   bank.trans, bank.disp, bank.card, bank.order) from a hardcoded local
   libname (/home/u64365845/projekt) and writes bank.Final_Table + a CSV
   export to the same hardcoded path.

   Here the libname points at a Jenner-local WORK-backed folder (see
   autoexec.sas) and each source table is built from a small inline
   DATALINES block that mirrors the real table's column names/types --
   this is the well-known Berka/PKDD'99 financial dataset schema the
   repo's own README documents column-by-column (district A1/A4/A11/A12/
   A15, disp OWNER/DISPONENT, card classic/junior/gold, order k_symbol
   SIPO/POJISTNE/UVER/LEASING, trans PRIJEM/VYDAJ + the SANKC. UROK penalty
   marker). The export path is rewritten to a relative path. Every PROC
   SQL join, every derived-variable formula (Wskaznik_DTI, Odchylenie_Salda,
   the 3-month trailing aggregates, etc.) is untouched. */

data bank.loan;
    length status $1;
    input loan_id account_id date :yymmdd6. amount duration payments status $;
    format date yymmdd6.;
    datalines;
5001 101 940301 96000 24 4000 A
5002 102 940601 60000 12 5000 B
5003 103 940801 300000 60 5000 C
5004 104 941001 120000 36 3333 A
5005 105 941201 48000 12 4000 D
5006 106 950115 84000 24 3500 C
5007 107 950301 180000 48 3750 A
5008 108 950501 36000 6 6000 C
5009 109 950701 240000 60 4000 B
5010 110 950901 54000 18 3000 A
;
run;

data bank.client;
    input client_id birth_number district_id;
    datalines;
1 706213 1
2 450204 2
3 720611 3
4 891025 1
5 556811 4
6 630930 5
7 880102 2
8 701122 6
9 545516 7
10 900814 1
;
run;

data bank.district;
    length A3 $20;
    input A1 A3 & $20. A4 A11 A12 A15;
    datalines;
1 Prague               1204953 12541 0.29 85677
2 central Bohemia      88884   8507  1.67 2183
3 central Bohemia      75232   8980  1.95 2135
4 central Bohemia      149893  9753  2.10 3016
5 south Bohemia        70646   8547  2.65 1563
6 south Bohemia        95616   9104  1.51 2299
7 north Bohemia        182027  9893  4.09 5623
;
run;

data bank.trans;
    length type $6 k_symbol $12;
    input trans_id account_id date :yymmdd6. type $ amount balance k_symbol $;
    format date yymmdd6.;
    datalines;
1 101 930105 PRIJEM 10000 10000 .
2 101 930601 PRIJEM 8000 17500 .
3 101 931201 VYDAJ 2000 16000 .
4 101 940101 PRIJEM 9000 24500 .
5 101 940201 VYDAJ 3000 22000 .
6 101 940215 VYDAJ 1500 20800 SANKC.UROK
7 102 930301 PRIJEM 12000 12000 .
8 102 930901 PRIJEM 7000 18500 .
9 102 940301 VYDAJ 4000 15000 .
10 102 940501 PRIJEM 6000 20500 .
11 103 930401 PRIJEM 20000 20000 .
12 103 931001 PRIJEM 15000 34500 .
13 103 940401 VYDAJ 5000 30000 .
14 103 940601 VYDAJ 2500 28000 SANKC.UROK
15 103 940715 PRIJEM 10000 37500 .
16 104 930501 PRIJEM 9000 9000 .
17 104 931101 PRIJEM 6000 14500 .
18 104 940701 VYDAJ 1000 13800 .
19 104 940901 PRIJEM 5000 18500 .
20 105 930601 PRIJEM 7500 7500 .
21 105 931201 PRIJEM 5000 12000 .
22 105 940901 VYDAJ 2000 10300 .
23 106 930701 PRIJEM 11000 11000 .
24 106 940101 PRIJEM 8500 19000 .
25 106 941001 VYDAJ 3000 16400 .
26 106 941201 PRIJEM 7000 23100 SANKC.UROK
27 107 930801 PRIJEM 14000 14000 .
28 107 940201 PRIJEM 9500 23000 .
29 107 941101 VYDAJ 4500 18900 .
30 108 930901 PRIJEM 6000 6000 .
31 108 940301 PRIJEM 4500 10200 .
32 108 950201 VYDAJ 1200 9200 .
33 109 931001 PRIJEM 16000 16000 .
34 109 940501 PRIJEM 10000 25500 .
35 109 950401 VYDAJ 5500 20400 .
36 110 931101 PRIJEM 8000 8000 .
37 110 940601 PRIJEM 6500 14200 .
38 110 950601 VYDAJ 2200 12300 .
;
run;

data bank.disp;
    length type $10;
    input disp_id client_id account_id type $;
    datalines;
1 1 101 OWNER
2 2 102 OWNER
3 3 103 OWNER
4 4 104 OWNER
5 5 105 OWNER
6 6 106 OWNER
7 7 107 OWNER
8 8 108 OWNER
9 9 109 OWNER
10 10 110 OWNER
;
run;

data bank.card;
    length type $7;
    input card_id disp_id type $ issued :yymmdd6.;
    format issued yymmdd6.;
    datalines;
1 1 classic 940115
2 4 gold 950203
3 7 junior 960310
;
run;

data bank.order;
    length k_symbol $10;
    input order_id account_id amount k_symbol $;
    datalines;
1 101 3372 SIPO
2 101 2144 POJISTNE
3 102 1200 UVER
4 103 5555 SIPO
5 104 1800 POJISTNE
6 104 900 SIPO
7 105 2500 LEASING
8 106 3000 SIPO
9 107 1150 POJISTNE
10 108 2200 SIPO
11 109 1980 SIPO
12 110 2700 POJISTNE
13 110 1500 SIPO
;
run;

data bank.account;
    length frequency $19;
    input account_id district_id frequency & $19. date :yymmdd6.;
    format date yymmdd6.;
    datalines;
101 1 POPLATEK MESICNE  930101
102 2 POPLATEK MESICNE  930215
103 3 POPLATEK TYDNE  930301
104 1 POPLATEK MESICNE  930410
105 4 POPLATEK PO OBRATU  930522
106 5 POPLATEK MESICNE  930601
107 2 POPLATEK MESICNE  930715
108 6 POPLATEK MESICNE  930801
109 7 POPLATEK MESICNE  930910
110 1 POPLATEK MESICNE  931001
;
run;

data loan_base;
    set bank.loan;

    if status in ('A', 'C') then Default = 0;
    else if status in ('B', 'D') then Default = 1;

    Kwota_Kredytu = amount;
    Dlugosc_Kredytu = duration;
    Rata_Kredytu = payments;

    rename date = Data_Kredytu;
run;

proc sql;
    create table client_geo as
    select
        c.client_id,
        c.district_id,
        1900 + input(substr(put(c.birth_number,z6.), 1, 2), 2.) as Rok_Urodzenia,
        case when input(substr(put(c.birth_number,z6.), 3, 2), 2.) > 50 then 1 else 0 end as Plec,

        d.A12 as Bezrobocie,
        d.A15 as Przestepczosc,
        d.A11 as Srednia_Pensja,
        d.A4  as Urbanizacja

    from bank.client c

    left join bank.district d
    on c.district_id = d.A1;
quit;

data client_final;
    set client_geo;

    Data_Urodzenia = mdy(7, 1, Rok_Urodzenia);
    drop Rok_Urodzenia;
run;

proc sql;
    create table trans_history as
    select
        t.*,
        l.loan_id,
        l.Data_Kredytu

    from
        bank.trans t,
        loan_base l
    where
        t.account_id = l.account_id
        and t.date < l.Data_Kredytu;
quit;

proc sql;
    create table feats_trans as
    select
        loan_id,

        mean(balance) as Srednie_Saldo,
        min(balance) as Min_Saldo,
        max(balance) as Max_Saldo,
        std(balance) as Odchylenie_Salda,
        sum(case when type='PRIJEM' then amount else 0 end) as Suma_Wplywow,
        sum(case when type='VYDAJ' then amount else 0 end) as Suma_Wydatkow,
        count(*) as Liczba_Transakcji,
        sum(case when k_symbol = 'SANKC.UROK' then 1 else 0 end) as Liczba_Kar,

        mean(case when (Data_Kredytu - date) <= 90 then balance else . end) as Srednie_Saldo_3M,
        min(case when (Data_Kredytu - date) <= 90 then balance else . end) as Min_Saldo_3M,
        sum(case when (Data_Kredytu - date) <= 90 and type='PRIJEM' then amount else 0 end) as Wplywy_3M

    from trans_history
    group by loan_id;
quit;

proc sql;
    create table feats_products as
    select
        a.account_id,

        a.date as Data_Zalozenia,
        case when a.frequency = 'POPLATEK MESICNE' then 1 else 0 end as Czestosc_Wyciagu,

        max(case when ca.card_id is not null then 1 else 0 end) as Posiada_Karte,
        max(case when ca.type = 'gold' then 1 else 0 end) as Posiada_Karte_Gold,


        count(distinct o.order_id) as Liczba_Zlecen,
        sum(o.amount) as Suma_Zlecen,
        sum(case when o.k_symbol = 'POJISTNE' then 1 else 0 end) as Oplaca_Ubezpieczenie,
        sum(case when o.k_symbol = 'SIPO' then 1 else 0 end) as Oplaca_Mieszkanie

    from
        bank.account a
        left join bank.disp d on a.account_id = d.account_id and d.type = 'OWNER'
        left join bank.card ca on d.disp_id = ca.disp_id
        left join bank.order o on a.account_id = o.account_id
    group by a.account_id, a.date, a.frequency;
quit;

proc sql;
    create table bank.Final_Table as
    select
        l.loan_id,
        l.Default,

        l.Kwota_Kredytu,
        l.Dlugosc_Kredytu,
        l.Rata_Kredytu,

        (l.Data_Kredytu - c.Data_Urodzenia) / 365.25 as Wiek,
        c.Plec, c.Bezrobocie, c.Przestepczosc, c.Srednia_Pensja, c.Urbanizacja,

        (l.Data_Kredytu - p.Data_Zalozenia) / 30.4 as Staz_Klienta,
        p.Czestosc_Wyciagu,
        coalesce(p.Posiada_Karte, 0) as Posiada_Karte,
        coalesce(p.Posiada_Karte_Gold, 0) as Posiada_Karte_Gold,
        coalesce(p.Liczba_Zlecen, 0) as Liczba_Zlecen,
        coalesce(p.Suma_Zlecen, 0) as Suma_Zlecen,
        coalesce(p.Oplaca_Ubezpieczenie, 0) as Oplaca_Ubezpieczenie,
        coalesce(p.Oplaca_Mieszkanie, 0) as Oplaca_Mieszkanie,

        coalesce(t.Srednie_Saldo, 0) as Srednie_Saldo,
        coalesce(t.Min_Saldo, 0) as Min_Saldo,
        coalesce(t.Max_Saldo, 0) as Max_Saldo,
        coalesce(t.Odchylenie_Salda, 0) as Odchylenie_Salda,
        coalesce(t.Suma_Wplywow, 0) as Suma_Wplywow,
        coalesce(t.Suma_Wydatkow, 0) as Suma_Wydatkow,
        coalesce(t.Liczba_Transakcji, 0) as Liczba_Transakcji,
        coalesce(t.Liczba_Kar, 0) as Liczba_Kar,
        coalesce(t.Srednie_Saldo_3M, 0) as Srednie_Saldo_3M,
        coalesce(t.Min_Saldo_3M, 0) as Min_Saldo_3M,
        coalesce(t.Wplywy_3M, 0) as Wplywy_3M,

        l.payments / ( (t.Wplywy_3M / 3) + 1 ) as Wskaznik_DTI,
        (coalesce(t.Suma_Wydatkow,0) + 1) / (coalesce(t.Suma_Wplywow,0) + 1) as Wskaznik_Oszczedzania

    from
        loan_base l
        left join bank.disp d on l.account_id = d.account_id and d.type = 'OWNER'
        left join client_final c on d.client_id = c.client_id
        left join feats_products p on l.account_id = p.account_id
        left join feats_trans t on l.loan_id = t.loan_id;
quit;

proc contents data=bank.Final_Table; run;

proc export data=bank.Final_Table
    outfile="Final_Table.csv"
    dbms=csv
    replace;
run;

proc print data=bank.Final_Table (obs=10); run;

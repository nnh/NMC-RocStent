**************************************************************************
Program Name : sae.sas
Study Name : NMC-RocStent
Author : Kato Kiroku
Date : 2019-03-22
SAS version : 9.4
**************************************************************************;


proc datasets library=work kill nolist; quit;

options mprint mlogic symbolgen minoperator;


*^^^^^^^^^^^^^^^^^^^^Current Working Directories^^^^^^^^^^^^^^^^^^^^;

*Find the current working directory;
%macro FIND_WD;

    %local _fullpath _path;
    %let _fullpath=;
    %let _path=;

    %if %length(%sysfunc(getoption(sysin)))=0 %then
      %let _fullpath=%sysget(sas_execfilepath);
    %else
      %let _fullpath=%sysfunc(getoption(sysin));

    %let _path=%substr(&_fullpath., 1, %length(&_fullpath.)
                       -%length(%scan(&_fullpath., -1, '\'))
                       -%length(%scan(&_fullpath., -2, '\')) -2);
    &_path.

%mend FIND_WD;

%let cwd=%FIND_WD;
%put &cwd.;

%inc "&cwd.\program\macro\libname.sas";


%macro FMTNUM2CHAR (variable);
    %let dsid=%sysfunc(open(&SYSLAST.));
    %let varnum=%sysfunc(varnum(&dsid,&variable));
    %let fmt=%sysfunc(varfmt(&dsid,&varnum));
    %let dsid=%sysfunc(close(&dsid));
    &fmt
%mend FMTNUM2CHAR;

data sae_report;
    set libads.sae_report;
    id=input(SUBJID, best12.);
    keep id sae1_trm sae1_grd;
    rename id=SUBJID;
run;

proc import datafile="&raw.\RocStent_¶”NŒ“ú,«•Ê.xlsx"
                    out=age
                    dbms=excel replace;
                    getnames=yes;
run;

data age_2;
    set age;
    format f3 YYMMDD10.;
    if f5=1 then delete;
    if missing(f2) then delete;
    keep f2 f3 f4;
    rename f2=SUBJID;
    label f2='Ç—á“o˜^”Ô†';
run;

proc sort data=age_2; by SUBJID; run;

proc import datafile="&raw.\RocStent_190215_1602.csv"
                    out=treatment
                    dbms=csv replace;
run;

data treatment_2;
    format SUBJID best12. GROUP $30.;
    set treatment;
    SUBJID=input(VAR1, best12.);
    if VAR2='A' then GROUP='©”­ŒÄ‹zŒQ(SPŒQ)';
    else if VAR2='B' then GROUP='‹Ø’oŠÉ–ò“Š—^ŒQ(MRŒQ)';
    keep SUBJID GROUP;
run;

proc sort data=treatment_2; by SUBJID; run;

data treatment_2;
    merge treatment_2 age_2 (in=a);
    by subjid;
    if a;
run;

data treatment_sp treatment_mr;
    set treatment_2;
    if group='©”­ŒÄ‹zŒQ(SPŒQ)' then output treatment_sp;
    else if group='‹Ø’oŠÉ–ò“Š—^ŒQ(MRŒQ)' then output treatment_mr;
run;

data _NULL_;
    set treatment_sp end=last;
    retain cnt 0;
    cnt+1;
    if last then call symputx("_TN_sp_", cnt);
run;

data _NULL_;
    set treatment_mr end=last;
    retain cnt 0;
    cnt+1;
    if last then call symputx("_TN_mr_", cnt);
run;

%put &_TN_sp_;
%put &_TN_mr_;


%macro COUNT (name, var, rdata, form);

    data &name._sp &name._mr;
        merge &rdata (in=a) treatment_2;
        by SUBJID;
        if a;
        if GROUP='©”­ŒÄ‹zŒQ(SPŒQ)' then output &name._sp;
        else if GROUP='‹Ø’oŠÉ–ò“Š—^ŒQ(MRŒQ)' then output &name._mr;
    run;

    proc freq data=&name._sp noprint;
        tables &var / out=x&name._sp;
    run;
    data x&name._sp;
        set x&name._sp;
        rename count=SP_count percent=S_percent;
    run;
    proc freq data=&name._mr noprint;
        tables &var / out=x&name._mr;
    run;
    data x&name._mr;
        set x&name._mr;
        rename count=MR_count percent=M_percent;
    run;

    proc sort data=x&name._sp; by &var; run;
    proc sort data=x&name._mr; by &var; run;

    data xx&name;
        merge x&name._sp x&name._mr;
        by &var;
        SP_percent=round(((SP_count/&_TN_sp_)*100), 0.1);
        MR_percent=round(((MR_count/&_TN_mr_)*100), 0.1);
        if missing(SP_count) then SP_count=0;
        if missing(SP_percent) then SP_percent=0;
        if missing(MR_count) then MR_count=0;
        if missing(MR_percent) then MR_percent=0;
    run;

    data y&name;
        format grade $24.;
        set xx&name;
        format &var &form;
        grade=put(&var, %FMTNUM2CHAR(&var));
        label grade='d“Ä‚È—LŠQ–Û';
        drop S_percent M_percent;
    run;

    proc sort data=y&name; by grade; run;

    data y&name;
        set y&name;
        drop &var;
    run;

%mend COUNT;

%COUNT (x_sae_report, sae1_trm, sae_report, FMT_2_F88.);

data sae;
    format grade SP_count SP_percent MR_count MR_percent;
    set Yx_sae_report;
    label MR_count='MRŒQ' MR_percent='MRŒQ(%)' SP_count='SPŒQ' SP_percent='SPŒQ(%)';
run;

%ds2csv (data=sae, runmode=b, csvfile=&out.\SAS\sae.csv, labels=Y);



%macro COUNT_grade (name, var, rdata, form);

%do i=1 %to 5;

    data &name._sp_&i &name._mr_&i;
        merge &rdata (in=a) treatment_2;
        by SUBJID;
        if a;
        if GROUP='©”­ŒÄ‹zŒQ(SPŒQ)' and sae1_grd=&i then output &name._sp_&i;
        else if GROUP='‹Ø’oŠÉ–ò“Š—^ŒQ(MRŒQ)' and sae1_grd=&i then output &name._mr_&i;
    run;

    proc freq data=&name._sp_&i noprint;
        tables &var / out=x&name._sp_&i;
    run;
    data x&name._sp_&i;
        set x&name._sp_&i;
        rename count=SP_count percent=S_percent;
    run;
    proc freq data=&name._mr_&i noprint;
        tables &var / out=x&name._mr_&i;
    run;
    data x&name._mr_&i;
        set x&name._mr_&i;
        rename count=MR_count percent=M_percent;
    run;

    proc sort data=x&name._sp_&i; by &var; run;
    proc sort data=x&name._mr_&i; by &var; run;

    data xx&name._&i;
        merge x&name._sp_&i x&name._mr_&i;
        by &var;
        SP_percent=round(((SP_count/&_TN_sp_)*100), 0.1);
        MR_percent=round(((MR_count/&_TN_mr_)*100), 0.1);
        if missing(SP_count) then SP_count=0;
        if missing(SP_percent) then SP_percent=0;
        if missing(MR_count) then MR_count=0;
        if missing(MR_percent) then MR_percent=0;
    run;

    data y&name._&i;
        format grade symptom $24. SP_count SP_percent MR_count MR_percent;
        set xx&name._&i;
        format &var &form;
        symptom=put(&var, %FMTNUM2CHAR(&var));
        label symptom='—LŠQ–Û';
        drop S_percent M_percent;
    run;

    proc sort data=y&name._&i; by grade; run;

    data y&name._&i;
        set y&name._&i;
        if _N_=1 then grade="ƒOƒŒ[ƒh&i";
        drop &var;
    run;

    %end;

%mend COUNT_grade;

%COUNT_grade (x_sae_report, sae1_trm, sae_report, FMT_2_F88.);

data yx_sae_report_grade;
    format grade symptom SP_count SP_percent MR_count MR_percent;
    set yx_sae_report_1 yx_sae_report_2 yx_sae_report_3 yx_sae_report_4 yx_sae_report_5;
    label MR_count='MRŒQ' MR_percent='MRŒQ(%)' SP_count='SPŒQ' SP_percent='SPŒQ(%)';
run;

%ds2csv (data=yx_sae_report_grade, runmode=b, csvfile=&out.\SAS\sae_grade.csv, labels=Y);

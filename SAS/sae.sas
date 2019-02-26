**************************************************************************
Program Name : sae.sas
Study Name : NMC-RocStent
Author : Kato Kiroku
Date : 2019-02-25
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
    keep id sae1_trm;
    rename id=SUBJID;
run;

proc import datafile="&raw.\RocStent_190215_1602.csv"
                    out=treatment
                    dbms=csv replace;
run;

data treatment_2;
    format SUBJID best12. GROUP $30.;
    set treatment;
    SUBJID=input(VAR1, best12.);
    if VAR2='A' then GROUP='é©î≠åƒãzåQ(SPåQ)';
    else if VAR2='B' then GROUP='ãÿíoä…ñÚìäó^åQ(MRåQ)';
    keep SUBJID GROUP;
run;

proc sort data=treatment_2; by SUBJID; run;


%macro COUNT (name, var, rdata, form);

    data &name._sp &name._mr;
        merge &rdata (in=a) treatment_2;
        by SUBJID;
        if a;
        if GROUP='é©î≠åƒãzåQ(SPåQ)' then output &name._sp;
        else if GROUP='ãÿíoä…ñÚìäó^åQ(MRåQ)' then output &name._mr;
    run;

    proc freq data=&name._sp noprint;
        tables &var / out=x&name._sp;
    run;
    data x&name._sp;
        set x&name._sp;
        rename count=SP_count percent=SP_percent;
    run;
    proc freq data=&name._mr noprint;
        tables &var / out=x&name._mr;
    run;
    data x&name._mr;
        set x&name._mr;
        rename count=MR_count percent=MR_percent;
    run;

    proc sort data=x&name._sp; by &var; run;
    proc sort data=x&name._mr; by &var; run;

    data xx&name;
        merge x&name._sp x&name._mr;
        by &var;
        SP_percent=round(SP_percent, 0.1);
        MR_percent=round(MR_percent, 0.1);
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
        label grade='èdìƒÇ»óLäQéñè€';
    run;

    proc sort data=y&name; by grade; run;

    data y&name;
        set y&name;
        drop &var;
    run;

%mend COUNT;

%COUNT (x_sae_report, sae1_trm, sae_report, FMT_2_F88.);

data sae;
    format grade MR_count MR_percent SP_count SP_percent;
    set Yx_sae_report;
    label MR_count='MRåQ' MR_percent='MRåQ(%)' SP_count='SPåQ' SP_percent='SPåQ(%)';
run;

%ds2csv (data=sae, runmode=b, csvfile=&out.\SAS\sae.csv, labels=Y);

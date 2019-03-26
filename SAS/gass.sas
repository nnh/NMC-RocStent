**************************************************************************
Program Name : gass.sas
Study Name : NMC-RocStent
Author : Kato Kiroku
Date : 2019-03-25
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

data ptdata;
    format id;
    set libads.ptdata;
    id=input(SUBJID, best12.);
    drop SUBJID;
    rename id=SUBJID;
run;

proc import datafile="&raw.\RocStent_ê∂îNåéì˙,ê´ï .xlsx"
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
    label f2='è«ó·ìoò^î‘çÜ';
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
    if VAR2='A' then GROUP='é©î≠åƒãzåQ(SPåQ)';
    else if VAR2='B' then GROUP='ãÿíoä…ñÚìäó^åQ(MRåQ)';
    keep SUBJID GROUP;
run;

proc sort data=treatment_2; by SUBJID; run;

data treatment_2;
    merge treatment_2 age_2 (in=a);
    by subjid;
    if a;
run;

proc import datafile="&raw.\RocStent_saihi.csv"
                    out=saihi
                    dbms=csv replace;
run;

data saihi;
    set saihi;
    SUBJID=input(VAR1, best12.);
    drop VAR1;
run;

proc sort data=saihi; by SUBJID; run;

data ptdata;
    merge ptdata saihi;
    by subjid;
    if var2=1 then delete;
    if var2=2 then delete;
run;


data frame;
    format title grade $72. SP_count MR_count best12.;
    title=' ';
    grade=' ';
    SP_count=0;
    SP_percent=0;
    MR_count=0;
    MR_percent=0;
    output;
run;

data data4box;
    merge ptdata treatment_2;
    by subjid;
    if group='é©î≠åƒãzåQ(SPåQ)' then group='SP';
    else if group='ãÿíoä…ñÚìäó^åQ(MRåQ)' then group='MR';
    label SpO2_min='Minimum SpO2 (%)' pH='Average pH' PaCO2='Average PaCO2' PF='Average P/F ratio' group='Group';
    keep group pH PaCO2 PF SpO2_min;
run;


%macro IQR (name, var, rdata, title);

    data &name._sp &name._mr;
        merge &rdata (in=a) treatment_2;
        by SUBJID;
        if a;
        if GROUP='é©î≠åƒãzåQ(SPåQ)' then output &name._sp;
        else if GROUP='ãÿíoä…ñÚìäó^åQ(MRåQ)' then output &name._mr;
    run;

    proc means data=&name._sp noprint;
        var &var;
        output out=x&name._sp n=n mean=mean std=std median=median q1=q1 q3=q3 min=min max=max;
    run;
    proc transpose data=x&name._sp out=xx&name._sp prefix=sp;
        var n mean std median q1 q3 min max;
    run;

    proc means data=&name._mr noprint;
        var &var;
        output out=x&name._mr n=n mean=mean std=std median=median q1=q1 q3=q3 min=min max=max;
    run;
    proc transpose data=x&name._mr out=xx&name._mr prefix=mr;
        var n mean std median q1 q3 min max;
    run;

    data y&name;
        merge frame xx&name._sp xx&name._mr;
        if _N_=1 then title="&title.";
        grade=upcase(_NAME_);
        SP_count=round(sp1, 0.1);
        MR_count=round(mr1, 0.1);
        keep title grade SP_count MR_count;
    run;

%mend IQR;


data glm;
    merge ptdata treatment_2 (in=a);
    by SUBJID;
    if a;
run;

ods graphics on;
ods pdf file="&out.\SAS\gass_bp_glm.pdf" startpage=no;

%macro PDF (var, title);

        proc sgplot data=data4box;
            vbox &var / category=group;
            xaxis values=('SP' 'MR');
            title &title;
        run;

    ods pdf startpage=no;

        proc glm data=glm;
            class group pre_PF pre_aw_stenosis;
            model &var=group pre_PF pre_aw_stenosis / ss2 ss3;
        run;

    ods pdf startpage=yes;

%mend PDF;

%PDF (ph, 'Average pH');
%PDF (paco2, 'Average PaCO2');
%PDF (pf, 'Average P/F ratio');
%PDF (SpO2_min, 'Minimum SpO2 (%)');

ods pdf close;
ods graphics off;


*pH;
%IQR (x_pH, pH, ptdata, èpíÜpHïΩãœíl);

*PaCO2;
%IQR (x_PaCO2, PaCO2, ptdata, èpíÜPaCO2ïΩãœíl);

*PF;
%IQR (x_PF, PF, ptdata, èpíÜP/Fî‰ïΩãœíl);

*SpO2_min;
%IQR (x_SpO2_min, SpO2_min, ptdata, èpíÜSpO2ç≈í·íl);

data gass;
    format title grade sp_count sp_percent mr_count mr_percent;
    set yx_pH yx_PaCO2 yx_PF yx_SpO2_min;
    label mr_count='MRåQ' sp_count='SPåQ';
run;

%ds2csv (data=gass, runmode=b, csvfile=&out.\SAS\gass.csv, labels=Y);

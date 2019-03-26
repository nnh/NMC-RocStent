**************************************************************************
Program Name : spo2.sas
Study Name : NMC-RocStent
Author : Kato Kiroku
Date : 2019-03-20
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

data ptdata;
    format id;
    set libads.ptdata;
    id=input(SUBJID, best12.);
    drop SUBJID;
    rename id=SUBJID;
    if SpO2_n=0 then answer='�Ȃ�';
    else if SpO2_n>=1 then answer='����';
run;

proc import datafile="&raw.\RocStent_���N����,����.xlsx"
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
    label f2='�Ǘ�o�^�ԍ�';
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
    if VAR2='A' then GROUP='�����ċz�Q(SP�Q)';
    else if VAR2='B' then GROUP='�ؒo�ɖ򓊗^�Q(MR�Q)';
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
run;


%macro COUNT (name, var, rdata, a2z, title);

    data &name._sp &name._mr;
        merge &rdata (in=a) treatment_2;
        by SUBJID;
        if a;
        if GROUP='�����ċz�Q(SP�Q)' then output &name._sp;
        else if GROUP='�ؒo�ɖ򓊗^�Q(MR�Q)' then output &name._mr;
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

    data frame_&name;
        format title grade $60. &var $24. SP_count SP_percent MR_count MR_percent best12.;
        do &var=&a2z;
          title=' ';
          grade=' ';
          SP_count=0;
          SP_percent=0;
          MR_count=0;
          MR_percent=0;
          output;
        end;
    run;

    proc sort data=x&name._sp; by &var; run;
    proc sort data=x&name._mr; by &var; run;
    proc sort data=frame_&name; by &var; run;    

    data xx&name;
        merge frame_&name x&name._sp x&name._mr;
        by &var;
        grade=compress(&var.);
        SP_percent=round(SP_percent, 0.1);
        MR_percent=round(MR_percent, 0.1);
        drop &var;
    run;

    proc sort data=xx&name; by grade; run;

    data y&name;
        set xx&name;
        if _N_=1 then title="&title.";
    run;

%mend COUNT;

%COUNT (x_SpO2_n, answer, ptdata, %NRSTR('����', '�Ȃ�'), %NRSTR(SpO2<95%�ƂȂ�����(�m�C�Y������)));

proc transpose data=yx_spo2_n out=tmp;
    var grade SP_count SP_percent MR_count MR_percent;
run;

data spo2;
    length group $12;
    set tmp;
    if _NAME_='MR_count' then do; group='MR�Q'; _NAME_='count'; end;
    else if _NAME_='MR_percent' then do; group='MR�Q'; _NAME_='percent'; end;
    else if _NAME_='SP_count' then do; group='SP�Q'; _NAME_='count'; end;
    else if _NAME_='SP_percent' then do; group='SP�Q'; _NAME_='percent'; end;
    if _N_=1 then delete;
    total=col1+col2;
    drop _LABEL_;
    label col1='��_�f�C�x���g����' col2='�Ȃ�' total='���v'  _NAME_='type';
run;

%ds2csv (data=spo2, runmode=b, csvfile=&out.\SAS\spO2.csv, labels=Y);



data logistic;
    merge ptdata treatment_2 (in=a);
    by SUBJID;
    if a;
run;

data logistic;
    set logistic;
run;

ods graphics on;
ods pdf file="&out.\SAS\spO2_logistic.pdf";
ods noptitle;
proc logistic data=logistic ALPHA=0.1;
    class group pre_PF(ref=first param=ref) pre_aw_stenosis / ref=last param=ref;
    model answer(event='����')=group pre_PF pre_aw_stenosis;
    oddsratio group;
run;
ods pdf close;
ods graphics off;

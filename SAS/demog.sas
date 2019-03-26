**************************************************************************
Program Name : demog.sas
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
run;

data age_2;
    merge age_2 saihi;
    by subjid;
    if var2=1 then delete;
run;

data frame;
    format title grade $36. SP_count SP_percent MR_count MR_percent $12.;
    title=' ';
    grade=' ';
    SP_count=' ';
    SP_percent=' ';
    MR_count=' ';
    MR_percent=' ';
    output;
run;


%macro IQR (name, var, rdata, title);

    %if &var in (hight weight bmi) %then %do;
        data ptdata;
            set ptdata;
            c=input(&var., best12.);
            drop &var.;
            rename c=&var.;
        run;
    %end;

    data &name._sp &name._mr;
        merge &rdata (in=a) treatment_2;
        by SUBJID;
        if a;
        if GROUP='é©î≠åƒãzåQ(SPåQ)' then output &name._sp;
        else if GROUP='ãÿíoä…ñÚìäó^åQ(MRåQ)' then output &name._mr;
    run;

    proc means data=&name._sp noprint;
        var &var;
        output out=x&name._sp n=n mean=m std=s median=median q1=q1 q3=q3 min=min max=max;
    run;
    data x&name._sp;
        set x&name._sp;
        mean=strip(put(round(m, 0.1), 8.1));
        std=strip(put(round(s, 0.1), 8.1));
    run;
    proc transpose data=x&name._sp out=xx&name._sp prefix=sp;
        var n mean std median q1 q3 min max;
    run;

    proc means data=&name._mr noprint;
        var &var;
        output out=x&name._mr n=n mean=m std=s median=median q1=q1 q3=q3 min=min max=max;
    run;
    data x&name._mr;
        set x&name._mr;
        mean=strip(put(round(m, 0.1), 8.1));
        std=strip(put(round(s, 0.1), 8.1));
    run;
    proc transpose data=x&name._mr out=xx&name._mr prefix=mr;
        var n mean std median q1 q3 min max;
    run;

    data y&name;
        format title grade $72. SP_count SP_percent MR_count MR_percent $12.;
        merge frame xx&name._sp xx&name._mr;
        if _N_=1 then title="&title.";
        grade=upcase(_NAME_);
        SP_count=sp1;
        MR_count=mr1;
        keep title grade SP_count SP_percent MR_count MR_percent;
    run;

%mend IQR;


%macro COUNT (name, var, rdata, form, a2z, title);

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
        SP_count=strip(input(count, $12.));
        SP_percent=strip(put(round(percent, 0.1), 8.1));
    run;
    proc freq data=&name._mr noprint;
        tables &var / out=x&name._mr;
    run;
    data x&name._mr;
        set x&name._mr;
        MR_count=strip(input(count, $12.));
        MR_percent=strip(put(round(percent, 0.1), 8.1));
    run;

    data frame_&name;
        format title grade $72. &var &form SP_count SP_percent MR_count MR_percent $12.;
        do &var=&a2z;
          title=' ';
          grade=' ';
          SP_count=' ';
          SP_percent=' ';
          MR_count=' ';
          MR_percent=' ';
          output;
        end;
    run;

    proc sort data=x&name._sp; by &var; run;
    proc sort data=x&name._mr; by &var; run;
    proc sort data=frame_&name; by &var; run;    

    data xx&name;
        merge frame_&name x&name._sp x&name._mr;
        by &var;
        %if &form=$24. %then %do;
            grade=compress(&var.);
        %end;
        %if &form NE $24. %then %do;
            grade=put(&var, %FMTNUM2CHAR(&var));
        %end;
        drop &var;
    run;

    proc sort data=xx&name; by grade; run;

    data y&name;
        set xx&name;
        if _N_=1 then title="&title.";
        if sp_count=' ' then sp_count='0';
        if sp_percent=' ' then sp_percent='0';
        if mr_count=' ' then mr_count='0';
        if mr_percent=' ' then mr_percent='0';
        keep title grade SP_count SP_percent MR_count MR_percent;
    run;

%mend COUNT;


*age;
data temp_age;
    set ptdata;
    id=input(SUBJID, best12.);
    keep id regist_date;
    rename id=SUBJID;
run;
data reg_age;
    merge age_2 (in=a) temp_age treatment_2;
    by SUBJID;
    if a;
    age=intck('YEAR', F3, regist_date);
    if (month(regist_date)<month(F3)) then age=age-1;
    else if (month(regist_date)=month(F3))
              and day(regist_date)<day(F3) then age=age-1;
run;
%IQR (x_age, age, reg_age, ìoò^éûîNóÓ);
 
*sex;
%COUNT (x_sex, F4, age_2, $36., %str('íjê´', 'èóê´'), ê´ï );

*height;
%IQR (x_height, hight, ptdata, êgí∑);

*weight;
%IQR (x_weight, weight, ptdata, ëÃèd);

*bmi;
%IQR (x_bmi, bmi, ptdata, BMI);

*asa;
%COUNT (x_asa, asa, ptdata, FMT_1_F6., 0 to 4, ASA);

*cause_disease;
%COUNT (x_cd, cause_disease, ptdata, FMT_3_F10., 0 to 4, å¥àˆéæä≥);

*O2;
%COUNT (x_o2, o2, ptdata, FMT_10_F4., 1 to 2, èpëOé_ëfìäó^ÇÃóLñ≥);

*pre_pf;
%COUNT (x_prepf, pre_pf, ptdata, FMT_22_F11., 1 to 2, èpëOP/Fî‰);

*pre_aw_stenosis;
%COUNT (x_pre_aw_stenosis, pre_aw_stenosis, ptdata, FMT_10_F4., 1 to 2, ãCìπÇÃã∑çÛïîà (éÂãCä«Çä‹Çﬁ));

*ope;
%COUNT (x_ope, ope, ptdata, FMT_6_F8., 0 to 1, ó\íËéËèpÇ‹ÇΩÇÕãŸã}éËèp);

*cardio;
%COUNT (x_cardio, ab_cardio_func, ptdata, FMT_10_F4., 1 to 2, êSã@î\àŸèÌÇÃóLñ≥);

*emphysema;
%COUNT (x_emphysema, emphysema, ptdata, FMT_10_F4., 1 to 2, îxãCéÓÇÃóLñ≥);


data demog;
    format title grade sp_count sp_percent mr_count mr_percent;
    set yx_age yx_sex yx_height yx_weight yx_bmi yx_asa yx_cd yx_o2 yx_prepf
    yx_pre_aw_stenosis yx_ope yx_cardio yx_emphysema;
    label mr_count='MRåQ' mr_percent='MRåQ(%)' sp_count='SPåQ' sp_percent='SPåQ(%)';
run;

%ds2csv (data=demog, runmode=b, csvfile=&out.\SAS\demog.csv, labels=Y);

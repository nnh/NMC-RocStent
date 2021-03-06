**************************************************************************
Program Name : gass.sas
Study Name : NMC-RocStent
Author : Kato Kiroku
Date : 2019-04-02
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

proc import datafile="&raw.\RocStent_¶Nú,«Ê.xlsx"
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
    label f2='Çáo^Ô';
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
    if VAR2='A' then GROUP='©­ÄzQ(SPQ)';
    else if VAR2='B' then GROUP='ØoÉò^Q(MRQ)';
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
    length visit 8;
    merge ptdata treatment_2;
    by subjid;
    if group='©­ÄzQ(SPQ)' then visit=1;
    else if group='ØoÉò^Q(MRQ)' then visit=1.01;
    if group='©­ÄzQ(SPQ)' then group='SP';
    else if group='ØoÉò^Q(MRQ)' then group='MR';
    label SpO2_min='Minimum SpO2 (%)' pH='Average pH' PaCO2='Average PaCO2' PF='Average P/F ratio' group='Group';
    keep group pH PaCO2 PF SpO2_min visit;
run;


%macro IQR (name, var, rdata, title);

    data &name._sp &name._mr;
        merge &rdata (in=a) treatment_2;
        by SUBJID;
        if a;
        if GROUP='©­ÄzQ(SPQ)' then output &name._sp;
        else if GROUP='ØoÉò^Q(MRQ)' then output &name._mr;
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


ods pdf file="&out.\SAS\gass_mean_sd.pdf" startpage=never title=' ';
options nodate nonumber papersize=A4 orientation=landscape;
ods layout gridded columns=2;
ods escapechar='^';

ods region width=12cm;
proc sgplot data=data4box;
    vline visit / response=ph group=group stat=mean limitstat=stddev numstd=1 markers limitattrs=(color=black) markerattrs=(color=black);
    xaxis values=(1 to 1.01 by 0.01) valuesdisplay=("SP" "MR") type=linear offsetmin=0.32 offsetmax=0.32 display=(NOLABEL);
    yaxis label='Mean pH (%)';
    keylegend "mybar" / title="";
    title 'A.  Mean pH';
run;
ods region width=12cm;
proc sgplot data=data4box;
    vline visit / response=paco2 group=group stat=mean limitstat=stddev numstd=1 markers limitattrs=(color=black) markerattrs=(color=black);
    xaxis values=(1 to 1.01 by 0.01) valuesdisplay=("SP" "MR") type=linear offsetmin=0.32 offsetmax=0.32 display=(NOLABEL);
    yaxis label='Mean PaCO2 (%)';
    keylegend "mybar" / title="";
    title 'B.  Mean PaCO2';
run;
ods region width=12cm;
proc sgplot data=data4box;
    vline visit / response=pf group=group stat=mean limitstat=stddev numstd=1 markers limitattrs=(color=black) markerattrs=(color=black);
    xaxis values=(1 to 1.01 by 0.01) valuesdisplay=("SP" "MR") type=linear offsetmin=0.32 offsetmax=0.32 display=(NOLABEL);
    yaxis label='Mean P/F ratio (%)';
    keylegend "mybar" / title="";
    title 'C.  Mean P/F ratio';
run;
ods region width=12cm;
proc sgplot data=data4box;
    vline visit / response=SpO2_min group=group stat=mean limitstat=stddev numstd=1 markers limitattrs=(color=black) markerattrs=(color=black);
    xaxis values=(1 to 1.01 by 0.01) valuesdisplay=("SP" "MR") type=linear offsetmin=0.32 offsetmax=0.32 display=(NOLABEL);
    yaxis label='Minimum SpO2 (%)';
    keylegend "mybar" / title="";
    title 'D.  Minimum SpO2';
run;
title;

ods layout end;
ods pdf close;

/*ods pdf file="&out.\SAS\gass_mean_sd_temp.pdf" startpage=never;*/
/*ods escapechar="^";*/
/**/
/*%sganno;*/
/**/
/*%let yaxislabel=Mean PaCO^{sub 2} (%);*/
/*%let titlelabel=B.  Mean PaCO^{sub 2};*/
/**/
/*data anno_via_macros;*/
/*  %sgtext(drawspace="wallpercent", x1=-20, y1=40, width=70, rotate=0, */
/*          textweight="bold", justify="center",*/
/*          label="&yaxislabel");*/
/*  %sgtext(drawspace="wallpercent", x1=50, y1=105, width=70, rotate=0,*/
/*          textweight="bold", justify="center",*/
/*          label="&titlelabel");*/
/*run;*/
/**/
/**/
/*proc sgplot data=data4box sganno=anno_via_macros;*/
/*    vline visit / response=paco2 group=group stat=mean limitstat=stddev numstd=1 markers limitattrs=(color=black) markerattrs=(color=black);*/
/*    xaxis values=(1 to 1.01 by 0.01) valuesdisplay=("SP" "MR") type=linear offsetmin=0.32 offsetmax=0.32 display=(NOLABEL);*/
/*/*    yaxis label='Mean PaCO^{sub 2} (%)';*/*/
/*    keylegend "mybar" / title="";*/
/*/*    title 'B.  Mean PaCO^{sub 2}';*/*/
/*run;*/
/*ods pdf close;*/

/*%macro PDF (var, title);*/

/*data glm;*/
/*    merge ptdata treatment_2 (in=a);*/
/*    by SUBJID;*/
/*    if a;*/
/*run;*/

*boxplot;
/*        proc sgplot data=data4box;*/
/*            vbox &var / category=group;*/
/*            xaxis values=('SP' 'MR');*/
/*            title &title;*/
/*        run;*/
/**/
/*    ods pdf startpage=no;*/
/**/
/*        proc glm data=glm;*/
/*            class group pre_PF pre_aw_stenosis;*/
/*            model &var=group pre_PF pre_aw_stenosis / ss2 ss3;*/
/*        run;*/
/**/
/*    ods pdf startpage=yes;*/

/*%mend PDF;*/

/*%PDF (ph, 'Mean pH (%)');*/
/*%PDF (paco2, 'Mean PaCO^{sub 2} (%)');*/
/*%PDF (pf, 'Mean P/F ratio (%)');*/
/*%PDF (SpO2_min, 'Minimum SpO2 (%)');*/


*pH;
%IQR (x_pH, pH, ptdata, ppH½Ïl);

*PaCO2;
%IQR (x_PaCO2, PaCO2, ptdata, pPaCO2½Ïl);

*PF;
%IQR (x_PF, PF, ptdata, pP/Fä½Ïl);

*SpO2_min;
%IQR (x_SpO2_min, SpO2_min, ptdata, pSpO2Åál);

data gass;
    format title grade sp_count sp_percent mr_count mr_percent;
    set yx_pH yx_PaCO2 yx_PF yx_SpO2_min;
    label mr_count='MRQ' sp_count='SPQ';
run;

%ds2csv (data=gass, runmode=b, csvfile=&out.\SAS\gass.csv, labels=Y);

**************************************************************************
Program Name : ope.sas
Study Name : NMC-RocStent
Author : Kato Kiroku
Date : 2019-03-26
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

proc import datafile="&raw.\RocStent_生年月日,性別.xlsx"
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
    label f2='症例登録番号';
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
    if VAR2='A' then GROUP='自発呼吸群(SP群)';
    else if VAR2='B' then GROUP='筋弛緩薬投与群(MR群)';
    keep SUBJID GROUP;
run;

proc sort data=treatment_2; by SUBJID; run;

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

data treatment_2;
    merge treatment_2 age_2 (in=a) saihi;
    by subjid;
    if a;
    if VAR2='1' then delete;
    drop VAR2 VAR3;
run;

data ptdata;
    merge ptdata saihi;
    by subjid;
    if var2=1 then delete;
run;

data ptdata_excluded;
    set ptdata;
    if var2=2 then delete;
run;

data frame;
    format title grade $72. SP_count SP_percent MR_count MR_percent $12.;
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
        if GROUP='自発呼吸群(SP群)' then output &name._sp;
        else if GROUP='筋弛緩薬投与群(MR群)' then output &name._mr;
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
        if GROUP='自発呼吸群(SP群)' then output &name._sp;
        else if GROUP='筋弛緩薬投与群(MR群)' then output &name._mr;
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


*aw_stenosis;
%COUNT (aw_stenosis_1, aw_stenosis_1, ptdata, $24., %str('TRUE', 'FALSE'), );
data yaw_stenosis_1;
    set yaw_stenosis_1;
    if grade='TRUE' then grade='主気管'; else delete;
run;
%COUNT (aw_stenosis_2, aw_stenosis_2, ptdata, $24., %str('TRUE', 'FALSE'), );
data yaw_stenosis_2;
    set yaw_stenosis_2;
    if grade='TRUE' then grade='気管分岐部'; else delete;
run;
%COUNT (aw_stenosis_3, aw_stenosis_3, ptdata, $24., %str('TRUE', 'FALSE'), );
data yaw_stenosis_3;
    set yaw_stenosis_3;
    if grade='TRUE' then grade='左主気管支'; else delete;
run;
%COUNT (aw_stenosis_4, aw_stenosis_4, ptdata, $24., %str('TRUE', 'FALSE'), );
data yaw_stenosis_4;
    set yaw_stenosis_4;
    if grade='TRUE' then grade='右主気管支'; else delete;
run;
data yx_aw_stenosis;
    set yaw_stenosis_1 yaw_stenosis_2 yaw_stenosis_3 yaw_stenosis_4;
    if _N_=1 then title="気道の狭窄部位";
run;

*aw_stenosis_p;
%IQR (x_anesthesia_time, anesthesia_time, ptdata, 麻酔時間(分));

*anesthesia_time;
%IQR (x_aw_stenosis_p, aw_stenosis_p, ptdata, 狭窄程度(%));

*ope_time;
%IQR (x_ope_time, ope_time, ptdata, 手術時間(分));

*ope_style;
%COUNT (x_ope_style, ope_style, ptdata, FMT_16_F26., 0 to 3, 術式);

*sum_venti_time;
%IQR (x_sum_venti_time, sum_venti_time, ptdata_excluded, 合計無換気時間(秒));

*non_ventilation;
%IQR (x_non_ventilation, non_ventilation, ptdata_excluded, 無換気回数);

*max_venti_time;
%IQR (x_max_venti_time, max_venti_time, ptdata_excluded, 最大無換気時間(秒));

*operator;
%COUNT (x_operator, operator, ptdata, FMT_13_F1., 0 to 1, オペレータ);

*stent;
%COUNT (x_stent, stent, ptdata, FMT_14_F25., 0 to 3, ステントの種類);

*stent_n;
%COUNT (x_stent_n, stent_n, ptdata, FMT_15_F6., 0 to 3, ステントの数);

*cauterization;
%COUNT (x_cauterization, cauterization, ptdata, FMT_10_F4., 1 to 2, 焼灼の有無);

*bucking;
%IQR (x_bucking, bucking, ptdata_excluded, バッキングの回数);

*assist_n;
%IQR (x_assist_n, assist_n, ptdata_excluded, 陽圧呼吸によるアシストの回数);

*assist_time;
%IQR (x_assist_time, assist_time, ptdata_excluded, 陽圧呼吸によるアシストの時間(秒));

*SpO2_n;
%IQR (x_SpO2_n, SpO2_n, ptdata, %NRSTR(SpO2<95%となった回数(ノイズを除く)));

*SpO2_min;
%IQR (x_SpO2_min, SpO2_min, ptdata, 術中SpO2最低値(ノイズを除く));

*pH;
%IQR (x_pH, pH, ptdata_excluded, pH平均値);

*PaCO2;
%IQR (x_PaCO2, PaCO2, ptdata_excluded, PaCO2平均値);

*PaO2;
%IQR (x_PaO2, PaO2, ptdata_excluded, PaO2平均値);

*PF;
%IQR (x_PF, PF, ptdata_excluded, P/F比平均値);

*ETCO2;
%IQR (x_ETCO2, ETCO2, ptdata, ETCO2最大値(mmHg));

*max_BIS;
%IQR (x_max_BIS, max_BIS, ptdata, 術中最高BIS値);

*min_BIS;
%IQR (x_min_BIS, min_BIS, ptdata, 術中最低BIS値);

*min_TCI;
%IQR (x_min_TCI, min_TCI, ptdata, 最低プロポフォールTCI濃度(μg/ml));

*max_TCI;
%IQR (x_max_TCI, max_TCI, ptdata, 最高プロポフォールTCI濃度(μg/ml));

*mean_TCI;
%IQR (x_mean_TCI, mean_TCI, ptdata, 平均プロポフォール維持濃度(μg/ml));

*min_remifentanil;
%IQR (x_min_remifentanil, min_remifentanil, ptdata, レミフェンタニル最低流量(μg/kg/min));

*max_remifentanil;
%IQR (x_max_remifentanil, max_remifentanil, ptdata, レミフェンタニル最高流量(μg/kg/min));

*mean_remifentanil;
%IQR (x_mean_remifentanil, mean_remifentanil, ptdata, 平均レミフェンタニル維持濃度(μg/kg/min));

*fentanil;
%IQR (x_fentanil, fentanil, ptdata, フェンタニル総投与量(μg));

*total_remifentanil;
%IQR (x_total_remifentanil, total_remifentanil, ptdata, レミフェンタニル総投与量(μg));

*total_rocuronium;
%IQR (x_total_rocuronium, total_rocuronium, ptdata, ロクロニウム総投与量(mg));


data ope;
    format title grade sp_count sp_percent mr_count mr_percent;
    set yx_aw_stenosis yx_aw_stenosis_p yx_anesthesia_time yx_ope_time yx_ope_style yx_sum_venti_time yx_non_ventilation
          yx_max_venti_time yx_operator yx_stent yx_stent_n yx_cauterization yx_bucking
          yx_assist_n yx_assist_time yx_SpO2_n yx_SpO2_min yx_pH yx_PaCO2 yx_PaO2 yx_PF
          yx_ETCO2 yx_max_BIS yx_min_BIS yx_min_TCI yx_max_TCI yx_mean_TCI
          yx_min_remifentanil yx_max_remifentanil yx_mean_remifentanil yx_fentanil
          yx_total_remifentanil yx_total_rocuronium;
    label mr_count='MR群' mr_percent='MR群(%)' sp_count='SP群' sp_percent='SP群(%)';
run;

%ds2csv (data=ope, runmode=b, csvfile=&out.\SAS\ope.csv, labels=Y);

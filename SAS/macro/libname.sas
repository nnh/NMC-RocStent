**************************************************************************
Program Name : libname.sas
Purpose : 
Author : Kato Kiroku
Date : 2019-02-20
SAS version : 9.4
**************************************************************************;

/*NOTES*/
  /*1. This program works only when file paths are as listed below.*/
      /* (Study Name)  -         input         -      ext      -  option.csv */
      /* (Study Name)  -         input         -      ext      -  sheet.csv */
      /* (Study Name)  -         input         -  rawdata  -  (rawdata).csv */
      /* (Study Name)  -  ptosh-format */
  /*2. Converted data will be exported to the "ADS" directory shown below.*/
      /* (Study Name)  -  ptosh-format  -  ads */


proc datasets library=work kill nolist; quit;

options mprint mlogic symbolgen minoperator;


*^^^^^^^^^^^^^^^^^^^^Current Working Directories^^^^^^^^^^^^^^^^^^^^;

*Find the current working directory;
%macro REFER2WD;

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

%mend REFER2WD;

%let ref=%REFER2WD;
%put &ref.;

libname libads "&ref.\ptosh-format\ads" access=readonly;
libname libout "&ref.\output";
libname library "&ref.\ptosh-format\ads";

%let ads=&ref.\ptosh-format\ads;
%let out=&ref.\output;
%let raw=&ref.\input\rawdata;

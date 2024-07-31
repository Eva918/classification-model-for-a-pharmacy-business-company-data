/*---------------------------------------------------------
  The options statement below should be placed
  before the data step when submitting this code.
---------------------------------------------------------*/
options VALIDMEMNAME=EXTEND VALIDVARNAME=ANY;


/*---------------------------------------------------------
  Before this code can run you need to fill in all the
  macro variables below.
---------------------------------------------------------*/
/*---------------------------------------------------------
  Start Macro Variables
---------------------------------------------------------*/
%let SOURCE_HOST=<Hostname>; /* The host name of the CAS server */
%let SOURCE_PORT=<Port>; /* The port of the CAS server */
%let SOURCE_LIB=<Library>; /* The CAS library where the source data resides */
%let SOURCE_DATA=<Tablename>; /* The CAS table name of the source data */
%let DEST_LIB=<Library>; /* The CAS library where the destination data should go */
%let DEST_DATA=<Tablename>; /* The CAS table name where the destination data should go */

/* Open a CAS session and make the CAS libraries available */
options cashost="&SOURCE_HOST" casport=&SOURCE_PORT;
cas mysess;
caslib _all_ assign;

/* Load ASTOREs into CAS memory */
proc casutil;
  Load casdata="Forest___DrugClass.sashdat" incaslib="Models" casout="Forest___DrugClass" outcaslib="casuser" replace;
Quit;

/* Apply the model */
proc cas;
  fcmpact.runProgram /
  inputData={caslib="&SOURCE_LIB" name="&SOURCE_DATA"}
  outputData={caslib="&DEST_LIB" name="&DEST_DATA" replace=1}
  routineCode = "

   /*------------------------------------------
   Generated SAS Scoring Code
     Date             : 28May2024:00:23:39
     Locale           : en_US
     Model Type       : Forest
     Interval variable: Price
     Interval variable: Quantity
     Interval variable: Sale_CONVERTED
     Class variable   : DrugClass
     Class variable   : ExpDate
     Response variable: DrugClass
     ------------------------------------------*/
declare object Forest___DrugClass(astore);
call Forest___DrugClass.score('CASUSER','Forest___DrugClass');
   /*------------------------------------------*/
   /*_VA_DROP*/ drop 'I_DrugClass'n 'P_DrugClassAnalgesic'n 'P_DrugClassAntibiotic'n 'P_DrugClassAntifungal'n 'P_DrugClassAntihistamine'n 'P_DrugClassAntiviral'n 'P_DrugClassCardiovascular'n 'P_DrugClassDermatological'n 'P_DrugClassDiabetes'n 'P_DrugClassGastrointestinal'n 'P_DrugClassHormonal'n 'P_DrugClassImmunosuppressant'n 'P_DrugClassNeurological'n 'P_DrugClassOncology'n 'P_DrugClassPsychotropic'n 'P_DrugClassRespiratory'n;
length 'I_DrugClass_7795'n $17;
      'I_DrugClass_7795'n='I_DrugClass'n;
'P_DrugClassAnalgesic_7795'n='P_DrugClassAnalgesic'n;
'P_DrugClassAntibiotic_7795'n='P_DrugClassAntibiotic'n;
'P_DrugClassAntifungal_7795'n='P_DrugClassAntifungal'n;
'P_DrugClassAntihistamine_7795'n='P_DrugClassAntihistamine'n;
'P_DrugClassAntiviral_7795'n='P_DrugClassAntiviral'n;
'P_DrugClassCardiovascular_7795'n='P_DrugClassCardiovascular'n;
'P_DrugClassDermatological_7795'n='P_DrugClassDermatological'n;
'P_DrugClassDiabetes_7795'n='P_DrugClassDiabetes'n;
'P_DrugClassGastrointestin_7795'n='P_DrugClassGastrointestinal'n;
'P_DrugClassHormonal_7795'n='P_DrugClassHormonal'n;
'P_DrugClassImmunosuppress_7795'n='P_DrugClassImmunosuppressant'n;
'P_DrugClassNeurological_7795'n='P_DrugClassNeurological'n;
'P_DrugClassOncology_7795'n='P_DrugClassOncology'n;
'P_DrugClassPsychotropic_7795'n='P_DrugClassPsychotropic'n;
'P_DrugClassRespiratory_7795'n='P_DrugClassRespiratory'n;
   /*------------------------------------------*/
";

run;
Quit;

/* Persist the output table */
proc casutil;
  Save casdata="&DEST_DATA" incaslib="&DEST_LIB" casout="&DEST_DATA%str(.)sashdat" outcaslib="&DEST_LIB" replace;
Quit;

session server;

/* Start checking for existence of each input table */
exists0=doesTableExist("CASUSER(evangeline.suciadi@student.umn.ac.id)", "PHARMACY_SALES_APRIL_2023");
if exists0 == 0 then do;
  print "Table "||"CASUSER(evangeline.suciadi@student.umn.ac.id)"||"."||"PHARMACY_SALES_APRIL_2023" || " does not exist.";
  print "UserErrorCode: 100";
  exit 1;
end;
print "Input table: "||"CASUSER(evangeline.suciadi@student.umn.ac.id)"||"."||"PHARMACY_SALES_APRIL_2023"||" found.";
/* End checking for existence of each input table */


  _dp_inputTable="PHARMACY_SALES_APRIL_2023";
  _dp_inputCaslib="CASUSER(evangeline.suciadi@student.umn.ac.id)";

  _dp_outputTable="b8bc99b6-1e63-44d0-b6b3-898b41496641";
  _dp_outputCaslib="CASUSER(evangeline.suciadi@student.umn.ac.id)";

dataStep.runCode result=r status=rc / code='/* BEGIN data step with the output table                                           data */
data "b8bc99b6-1e63-44d0-b6b3-898b41496641" (caslib="CASUSER(evangeline.suciadi@student.umn.ac.id)" promote="no");

    length
       "Sale"n varchar(256)
       "Sale_CONVERTED"n 8
    ;
    format
        "Sale_CONVERTED"n BEST16.
    ;

    /* Set the input                                                                set */
    set "PHARMACY_SALES_APRIL_2023" (caslib="CASUSER(evangeline.suciadi@student.umn.ac.id)"  );

    /* BEGIN statement A33FCBC5_DEE1_4E48_A842_8A44B7B6391C                  calccolumn */
    "Sale"n = Price * Quantity;
    /* END statement A33FCBC5_DEE1_4E48_A842_8A44B7B6391C                    calccolumn */

    /* BEGIN statement 192d33e0_da9c_4744_8ec9_c78725f2bd49               dqstandardize */
    "Time"n = dqstandardize ("Time"n, "Date (DMY)", "ENUSA");
    /* END statement 192d33e0_da9c_4744_8ec9_c78725f2bd49                 dqstandardize */

    /* BEGIN statement_5b9646b5_bd31_41ab_b009_981ed56daa19              convert_column */
    "Sale_CONVERTED"n= INPUT(strip("Sale"n),BEST16.);
    /* END statement_5b9646b5_bd31_41ab_b009_981ed56daa19                convert_column */

/* END data step                                                                    run */
run;
';
if rc.statusCode != 0 then do;
  print "Error executing datastep";
  exit 2;
end;
  _dp_inputTable="b8bc99b6-1e63-44d0-b6b3-898b41496641";
  _dp_inputCaslib="CASUSER(evangeline.suciadi@student.umn.ac.id)";

  _dp_outputTable="PHARMACY_SALES_APRIL_2023_NEW";
  _dp_outputCaslib="CASUSER(evangeline.suciadi@student.umn.ac.id)";

srcCasTable="b8bc99b6-1e63-44d0-b6b3-898b41496641";
srcCasLib="CASUSER(evangeline.suciadi@student.umn.ac.id)";
tgtCasTable="PHARMACY_SALES_APRIL_2023_NEW";
tgtCasLib="CASUSER(evangeline.suciadi@student.umn.ac.id)";
saveType="sashdat";
tgtCasTableLabel="";
replace=1;
saveToDisk=1;

exists = doesTableExist(tgtCasLib, tgtCasTable);
if (exists !=0) then do;
  if (replace == 0) then do;
    print "Table already exists and replace flag is set to false.";
    exit ({severity=2, reason=5, formatted="Table already exists and replace flag is set to false.", statusCode=9});
  end;
end;

if (saveToDisk == 1) then do;
  /* Save will automatically save as type represented by file ext */
  saveName=tgtCasTable;
  if(saveType != "") then do;
    saveName=tgtCasTable || "." || saveType;
  end;
  table.save result=r status=rc / caslib=tgtCasLib name=saveName replace=replace
    table={
      caslib=srcCasLib
      name=srcCasTable
    };
  if rc.statusCode != 0 then do;
    return rc.statusCode;
  end;
  tgtCasPath=dictionary(r, "name");

  dropTableIfExists(tgtCasLib, tgtCasTable);
  dropTableIfExists(tgtCasLib, tgtCasTable);

  table.loadtable result=r status=rc / caslib=tgtCasLib path=tgtCasPath casout={name=tgtCasTable caslib=tgtCasLib} promote=1;
  if rc.statusCode != 0 then do;
    return rc.statusCode;
  end;
end;

else do;
  dropTableIfExists(tgtCasLib, tgtCasTable);
  dropTableIfExists(tgtCasLib, tgtCasTable);
  table.promote result=r status=rc / caslib=srcCasLib name=srcCasTable target=tgtCasTable targetLib=tgtCasLib;
  if rc.statusCode != 0 then do;
    return rc.statusCode;
  end;
end;


dropTableIfExists("CASUSER(evangeline.suciadi@student.umn.ac.id)", "b8bc99b6-1e63-44d0-b6b3-898b41496641");

function doesTableExist(casLib, casTable);
  table.tableExists result=r status=rc / caslib=casLib table=casTable;
  tableExists = dictionary(r, "exists");
  return tableExists;
end func;

function dropTableIfExists(casLib,casTable);
  tableExists = doesTableExist(casLib, casTable);
  if tableExists != 0 then do;
    print "Dropping table: "||casLib||"."||casTable;
    table.dropTable result=r status=rc/ caslib=casLib table=casTable quiet=0;
    if rc.statusCode != 0 then do;
      exit();
    end;
  end;
end func;

/* Return list of columns in a table */
function columnList(casLib, casTable);
  table.columnInfo result=collist / table={caslib=casLib,name=casTable};
  ndimen=dim(collist['columninfo']);
  featurelist={};
  do i =  1 to ndimen;
    featurelist[i]=upcase(collist['columninfo'][i][1]);
  end;
  return featurelist;
end func;

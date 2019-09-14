 sqlite3 datarp.db<<EOF
.echo on

CREATE TABLE runparams_infodef(
  "RowNum" INTEGER,
  "ProblemNum" INTEGER,
  "MaxTreeDepth" INTEGER,
  "SavePop" INTEGER,
  "UseERCS" INTEGER,
  "Pop" INTEGER,
  "MaxGen" INTEGER,
  "NumIndRuns" INTEGER,
  "LawnWidth" INTEGER,
  "LawnHeight" INTEGER,
  "FitCases" INTEGER
);
CREATE TABLE runparams_inputfile(
  "RowNum" INTEGER,
  "ProblemNum" INTEGER,
  "Kernel" INTEGER,
  "IndRunNum" INTEGER,
  "wADF" TEXT,
  "ADF" TEXT,
  "Types" TEXT,
  "Constraints" TEXT,
  "acgpwhat" INTEGER,
  "MaxTreeDepth" INTEGER,
  "Pop" INTEGER,
  "NumIndRuns" INTEGER,
  "LawnWidth" INTEGER,
  "LawnHeight" INTEGER,
  "FitCases" INTEGER,
  "InitMethod" TEXT,
  "InitDepth" TEXT,
  "AppUseGenRamp" INTEGER,
  "Tree0MaxDepth" INTEGER,
  "Tree1MaxDepth" INTEGER,
  "Tree2MaxDepth" INTEGER,
  "AppGenRampMaxTreeDepth" INTEGER,
  "AppGenRampInterval" INTEGER,
  "InitDepthABS" TEXT,
  "InitRandomoAttempts" INTEGER,
  "ACGPUseTreesPrct" REAL,
  "ACGPSelectAll" INTEGER,
  "ACGPGenStartPrct" REAL,
  "ACGPGenStep" INTEGER,
  "ACGPGenSlope" INTEGER,
  "ACGPStopOnTerm" INTEGER,
  "BreedOper1" TEXT, 
  "BreedOper1Select" TEXT, 
  "BreedOper1SelectSize" INTEGER, 
  "BreedOper1Depth" TEXT, 
  "BreedOper1Rate" REAL, 
  "BreedOper2" TEXT, 
  "BreedOper2Select" TEXT, 
  "BreedOper2SelectSize" INTEGER, 
  "BreedOper2Depth" TEXT, 
  "BreedOper2Rate" REAL, 
  "BreedOper3" TEXT, 
  "BreedOper3Select" TEXT, 
  "BreedOper3SelectSize" INTEGER, 
  "BreedOper3Depth" TEXT, 
  "BreedOper3Rate" REAL, 
  "BreedOper4" TEXT, 
  "BreedOper4Select" TEXT,
  "BreedOper4SelectSize" INTEGER, 
  "BreedOper4Depth" TEXT, 
  "BreedOper4Rate" REAL 
);
.mode csv
.import ./runparams0.csv runparams_infodef
.import ./runparams1.csv runparams_inputfile
.exit
EOF

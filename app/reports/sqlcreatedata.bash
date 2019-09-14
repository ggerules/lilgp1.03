
sqlite3 data.db<<EOF
.echo on
CREATE TABLE sttlong(
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
  "GenNum" INTEGER,
  "SubPopNum" INTEGER,
  "MeanStdFitnessOfGen" REAL,
  "StdFitnessBestOfGenInd" REAL,
  "StdFitnessWorstOfGenInd" REAL,
  "MeanTreeSizeOfGen" REAL,
  "MeanTreeDepthOfGen" REAL,
  "TreeSizeBestOfGenInd" INTEGER,
  "TreeDepthBestOfGenInd" INTEGER,
  "TreeSizeWorstOfGenInd" INTEGER,
  "TreeDepthWorstOfGenInd" REAL,
  "MeanStdFitnessOfRun" REAL,
  "StdFitnessBestOfRunInd" REAL,
  "StdFitnessWorstOfRunInd" REAL,
  "MeanTreeSizeOfRun" REAL,
  "MeanTreeDepthOfRun" REAL,
  "TreeSizeBestOfRunInd" INTEGER,
  "TreeDepthBestOfRunInd" INTEGER,
  "TreeSizeWorstOfRunInd" INTEGER,
  "TreeDepthWorstOfRunInd" INTEGER
);
CREATE TABLE beststatslong(
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
  "Hits" INTEGER,
  "Gen" INTEGER,
  "Nodes" INTEGER,
  "Depth" INTEGER
);
CREATE TABLE evaltimelong(
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
  "EvalTime" REAL
);
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
  "LawnDepth" INTEGER,
  "NFlowers" INTEGER,
  "FitCases" INTEGER
);
CREATE TABLE runparams_inputfile(
  "RowNum" INTEGER,
  "ProblemNum" INTEGER,
  "Kernel" INTEGER,
  "wADF" TEXT,
  "ADF" TEXT,
  "Types" TEXT,
  "Constraints" TEXT,
  "acgpwhat" INTEGER,
  "MaxTreeDepth" INTEGER,
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
.import ./sttlong.csv sttlong
.import ./beststatslong.csv beststatslong
.import ./evaltimelong.csv evaltimelong
.import ./runparams0.csv runparams_infodef
.import ./runparams1.csv runparams_inputfile
.exit
EOF

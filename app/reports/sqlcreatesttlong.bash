
sqlite3 data.db
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
.mode csv
.import ./sttlong.csv sttlong
.exit

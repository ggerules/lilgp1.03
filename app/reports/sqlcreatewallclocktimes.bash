 sqlite3 data.db<<EOF
.echo on
CREATE TABLE wallclocktimes(
  "RowNum" INTEGER,
  "ProblemNum" INTEGER,
  "Hours" INTEGER,
  "Min" INTEGER,
  "Sec" INTEGER,
  "MicroSec" INTEGER
);
.mode csv
.import ./wallclocktimes.csv wallclocktimes 
.exit
EOF

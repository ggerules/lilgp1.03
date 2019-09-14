#!/bin/bash
#sqlite3 data.db "select * from sttlong where (wADF in ('y')) and (ADF in ('y'))  and (ProblemNum = 3 and Kernel = 0 and IndRunNum = 1);"
#sqlite3 data.db "select * from beststatslong where (wADF in ('y')) and (ADF in ('y'))  and (ProblemNum = 3 and Kernel = 0 and IndRunNum = 1);"
#sqlite3 data.db "select * from beststatslong where (wADF in ('y')) and (ADF in ('y'))  and (ProblemNum = 3 and Kernel = 0 );"
#sqlite3 data.db "select Hits from beststatslong where (wADF in ('y')) and (ADF in ('y'))  and (ProblemNum = 3 and Kernel = 0 );"

#sqlite3 data.db "select Hits from beststatslong where wADF in ('y') and ADF in ('y') and Types in ('n') and Constraints in ('n') and acgpwhat in ('n') and ProblemNum = 37 and Kernel = 0"

#sqlite3 data.db "select Hits from beststatslong where wADF in ('y') and ADF in ('y') and Types in ('n') and Constraints in ('n') and acgpwhat in ('n') and ProblemNum = 12 and Kernel = 2"

#ProblemNum Kernel IndRunNum wADF ADF Types Constraints acgpwhat MaxTreeDepth Hits

#sqlite3 data.db "select ProblemNum,Kernel,IndRunNum,wADF,ADF,Types,Constraints,acgpwhat,MaxTreeDepth,Hits from beststatslong where wADF in ('y') and ADF in ('y') and Types in ('n') and Constraints in ('n') and acgpwhat in ('n') and ProblemNum = 37 and Kernel = 0"
#sqlite3 data.db "select * from beststatslong where wADF in ('y') and ADF in ('y') and Types in ('n') and Constraints in ('n') and acgpwhat in ('n') and ProblemNum = 37 and Kernel = 0"

#sqlite3 data.db "select Hits from beststatslong where wADF in ('y') and ADF in ('y') and Types in ('n') and Constraints in ('n') and acgpwhat in ('n') and ProblemNum = 23 and Kernel = 2"

#sqlite3 data.db "select Hits from beststatslong where wADF in ('y') and ADF in ('y') and Types in ('n') and Constraints in ('n') and acgpwhat in ('n') and ProblemNum = 24 and Kernel = 2"

#sqlite3 data.db "select Hits from beststatslong where wADF in ('y') and ADF in ('y') and Types in ('n') and Constraints in ('n') and acgpwhat in ('3') and ProblemNum = 24 and Kernel = 4"

#sqlite3 data.db "select Hits,Gen,Nodes,Depth from beststatslong where wADF in ('y') and ADF in ('y') and Types in ('n') and Constraints in ('n') and acgpwhat in ('3') and ProblemNum = 5 and Kernel = 4"

#sqlite3 data.db "select EvalTime from evaltimelong where wADF in ('y') and ADF in ('y') and Types in ('n') and Constraints in ('n') and acgpwhat in ('n') and ProblemNum = 103 and Kernel = 0"

#sqlite3 data.db "select EvalTime from evaltimelong where wADF in ('y') and ADF in ('y') and Types in ('n') and Constraints in ('n') and acgpwhat in ('3') and ProblemNum = 104 and Kernel = 4"

sqlite3 data.db "select * from evaltimelong where wADF in ('y') and ADF in ('y') and Types in ('n') and Constraints in ('n') and acgpwhat in ('3') and ProblemNum = 104 and Kernel = 4"

#sqlite3 data.db "select Hits,Gen,Nodes,Depth from beststatslong where wADF in ('y') and ADF in ('y') and Types in ('n') and Constraints in ('n') and acgpwhat in ('n') and ProblemNum = 103 and Kernel = 0"

#sqlite3 data.db "select Hits,Gen,Nodes,Depth from beststatslong where wADF in ('y') and ADF in ('y') and Types in ('n') and Constraints in ('n') and acgpwhat in ('3') and ProblemNum = 103 and Kernel = 4"

#runparams_infodef
#sqlite3 data.db "select * from runparams_infodef where ProblemNum = 103 "

#runparams_inputfile
#sqlite3 data.db "select * from runparams_inputfile where wADF in ('y') and ADF in ('y') and Types in ('n') and Constraints in ('n') and acgpwhat in ('3') and ProblemNum = 103 and Kernel = 4"


exit 0

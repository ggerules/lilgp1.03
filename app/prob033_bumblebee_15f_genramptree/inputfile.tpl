[+ AutoGen5 template +]
[+ FOR objlst +][+IF (exist? "kname")+]
#dirname=[+dirname+]
output.detail = [+output_detail+][+
IF(or (match-value? == "kcat" "cgp2p1")(match-value? == "kcat" "acgp1p1p2")(match-value? == "kcat" "acgp2p1"))+]
cgp_interface = interface.file[+
ENDIF+]

init.method = half_and_half
init.depth = 2-7 

app.use_genramp=1
tree[0].max_depth=5
tree[1].max_depth=5
tree[2].max_depth=5
app.genramp_max_tree_depth=17
app.genram_interval=4
[+IF(or (match-value? == "kcat" "cgp2p1")(match-value? == "kcat" "acgp1p1p2")(match-value? == "kcat" "acgp2p1"))+]
init.depth_abs = true
init.random_attempts=200
[+ENDIF+]
[+IF (or (match-value? == "kcat" "acgp1p1p2")(match-value? == "kcat" "acgp2p1"))+]
acgp.use_trees_prct = 0.02
acgp.select_all = 0
acgp.gen_start_pct = 0.0125
acgp.gen_step = 20
acgp.gen_slope = 1
acgp.stop_on_term = 1
[+ENDIF+][+
IF(match-value? == "what" "3")+]
breed_phases = 4

breed[1].operator = crossover, select=(tournament, size=7)
breed[1].rate = 0.85

breed[2].operator = mutation, select=(tournament, size=7), depth=3-5
breed[2].rate = 0.1

breed[3].operator = reproduction, select=(tournament, size=7)
breed[3].rate = 0.05

breed[4].operator = regrow, select=(worst )
breed[4].rate = 0.05[+
ELSE+]
breed_phases = 3

breed[1].operator = crossover, select=(tournament, size=7)
breed[1].rate = 0.85

breed[2].operator = mutation, select=(tournament, size=7), depth=3-5
breed[2].rate = 0.1

breed[3].operator = reproduction, select=(tournament, size=7)
breed[3].rate = 0.05
[+ENDIF+]
-|[+ENDIF+][+ ENDFOR +]

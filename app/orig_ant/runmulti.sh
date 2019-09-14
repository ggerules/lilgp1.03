#!/bin/sh
START=$(date +%s)

for x in `cat ./cnt`; do
./gp -p random_seed=1 -p output.basename=./tmp/cart_rs$x -p max_depth=$x -p init.depth=2-5 -f input.file
done;

END=$(date +%s)
DIFF=$(( $END - $START ))
echo "It took $DIFF seconds"
echo "done"


#!/bin/bash
find -name "*.$1" -type f -exec du -bc {} + | grep total$ | cut -f1 | awk '{ total += $1 }; END { print total }'

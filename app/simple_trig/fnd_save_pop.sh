#!/bin/bash
find . -name "*.sh" -type f -exec grep -nH "app.save_pop=" "{}" \; | sort -r


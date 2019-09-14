#!/bin/bash
find . -name "*.sh" -type f -exec grep -nH "numindruns=" "{}" \; | sort -r


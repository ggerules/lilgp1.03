#!/bin/bash
find . -name "*.pop" | parallel xz -zv2
find . -name "*.his" | parallel xz -zv2


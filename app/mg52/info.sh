#!/bin/bash

echo "*****"
find . -name "$1-0-*-y-n-n-n-n*.bst" -exec grep -H hits "{}" \; | uniq
find . -name "$1-0-*-y-n-n-n-n*.bst" -exec grep -H generation "{}" \; | uniq
find . -name "$1-0-*-y-n-n-n-n*.bst" -exec grep -H nodes "{}" \; | uniq
find . -name "$1-0-*-y-n-n-n-n*.bst" -exec grep -H depth "{}" \; | uniq
echo "*****"
find . -name "$1-0-*-y-y-n-n-n*.bst" -exec grep -H hits "{}" \; | uniq
find . -name "$1-0-*-y-y-n-n-n*.bst" -exec grep -H generation "{}" \; | uniq
find . -name "$1-0-*-y-y-n-n-n*.bst" -exec grep -H nodes "{}" \; | uniq
find . -name "$1-0-*-y-y-n-n-n*.bst" -exec grep -H depth "{}" \; | uniq
echo "*****"
find . -name "$1-4-*-y-y-n-n-3*.bst" -exec grep -H hits "{}" \; | uniq
find . -name "$1-4-*-y-y-n-n-3*.bst" -exec grep -H generation "{}" \; | uniq
find . -name "$1-4-*-y-y-n-n-3*.bst" -exec grep -H nodes "{}" \; | uniq
find . -name "$1-4-*-y-y-n-n-3*.bst" -exec grep -H depth "{}" \; | uniq

echo "*****"
find . -name "$2-2-*-y-y-n-n-n*.bst" -exec grep -H hits "{}" \; | uniq
find . -name "$2-2-*-y-y-n-n-n*.bst" -exec grep -H generation "{}" \; | uniq
find . -name "$2-2-*-y-y-n-n-n*.bst" -exec grep -H nodes "{}" \; | uniq
find . -name "$2-2-*-y-y-n-n-n*.bst" -exec grep -H depth "{}" \; | uniq

echo "*****"
find . -name "$2-4-*-y-y-n-n-3*.bst" -exec grep -H hits "{}" \; | uniq
find . -name "$2-4-*-y-y-n-n-3*.bst" -exec grep -H generation "{}" \; | uniq
find . -name "$2-4-*-y-y-n-n-3*.bst" -exec grep -H nodes "{}" \; | uniq
find . -name "$2-4-*-y-y-n-n-3*.bst" -exec grep -H depth "{}" \; | uniq


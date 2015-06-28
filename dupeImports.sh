#!/bin/bash

set -e

read -e -p "Enter path to Xcode project: " FILES

eval FILES=$FILES

for f in $FILES/*.{h,m}
do
	MYVAR=$(sed -n '/^#import/p' "$f" | uniq -c | sed -n '/[2-9] #import/p' | sort -nr)
	if [ -n "$MYVAR" ]; then
		echo "$f"
		echo "$MYVAR"
	fi
done

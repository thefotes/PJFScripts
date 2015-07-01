#!/bin/bash
# Prints a sorted list of authors to a repository sorted by commit count

git shortlog -ns --no-merges | sort -r

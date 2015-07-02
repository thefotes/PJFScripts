#!/bin/bash

# Prints out all of the extensions in a folder w/ counts

find . -type f | awk -F'[.]' '{print $NF}' | sort | uniq -c | sort -nr

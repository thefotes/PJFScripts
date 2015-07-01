#!/bin/bash

# Delete branch locally, then prune the remotes

git branch -D $1
git fetch -p

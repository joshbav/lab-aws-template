#!/bin/bash
# This is just to update git
git config user.name “joshbav” 
git add -A
git commit -m "Scripted commit $(date +%d-%b-%Y-%I:%M:%S%p)"
git push -u origin master

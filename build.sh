git config user.name “joshbav” 
git add *
git commit -m "scripted commit $(date +%d-%b-%Y-%I:%M:%S)"
git push -u origin master

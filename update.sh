echo "Register files to actual github tracker"
git add .;

echo "Adding actual tracked files to a commit"
git commit -m "New commit"

echo "Pushing files to remote"
git push

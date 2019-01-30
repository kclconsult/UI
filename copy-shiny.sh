cp -R /home/kai/consult/* .
git add .
git commit -m "Update"
pkill -f ssh-agent
eval "$(ssh-agent -s)"
ssh-add /home/martin/.ssh/consult-test-environment
git push

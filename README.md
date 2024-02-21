# alz-cptblue

~~~bash
git status
terraform init
~~~


## Change Firewall SKU

### New branch

~~~bash
# show the current branch
git branch --show-current # should be main
# create branch to change fw sku
git branch change-fw-sku
# switch to the new branch
git checkout change-fw-sku
~~~

Modify the main.tf file to change the firewall sku to basic.

### Commit and Pull requewst via github cli

~~~bash
terraform fmt
terraform validate
# get current git status
git status
# commit all your changes
git add .
git commit -am "Change fw sku in main.tf"
git push --set-upstream origin change-fw-sku
gh pr create --title "change fw sku to basic" --body "Change the current az fw sku to basic and remove lock" --base main
~~~

Approve the pull request and merge it via the web interface.

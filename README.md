# alz-cptblue

~~~bash
git status
terraform init
~~~


## Change Firewall SKU

### New branch change-fw-sku

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
terraform plan -out=tfplan-change-fw-sku
# get current git status
git status
# commit all your changes
git add .
git commit -m "Change fw sku in main.tf"
git push --set-upstream origin change-fw-sku
gh pr create --title "change fw sku to basic" --body "Change the current az fw sku to basic and remove lock" --base main
~~~

Approve the pull request and merge it via the web interface.

## Configure Hub DNS and Log Analytics

### New branch dns-law-config

~~~bash
# show the current branch
git branch --show-current # should be main
# create branch to change fw sku
git branch dns-law-config
# switch to the new branch
git checkout dns-law-config
~~~

Modify the main.tf file to change the firewall sku to basic.

### Commit and Pull requewst via github cli

~~~bash
terraform fmt
terraform validate
terraform plan -out=tfplan-dns-law-config
# get current git status
git status
# commit all your changes
git add .
git commit -m "dns-law-config"
git push --set-upstream origin dns-law-config
gh pr create --title "dns-law-config" --body "dns-law-config" --base main
~~~

Approve the pull request and merge it via the web interface.


## Create LZ0

### New branch create-lz0

~~~bash
# show the current branch
git branch --show-current # should be main
# create branch to change fw sku
git branch create-lz0
# switch to the new branch
git checkout create-lz0
~~~

Modify the main.tf file to change the firewall sku to basic.

### Commit and Pull requewst via github cli

~~~bash
terraform init # because of lz vending module
terraform fmt
terraform validate
terraform plan -out=tfplan-create-lz0
# get current git status
git status
# commit all your changes
git add .
git commit -m "create-lz0"
git push --set-upstream origin create-lz0
gh pr create --title "create-lz0" --body "create-lz0" --base main
~~~

Approve the pull request and merge it via the web interface.


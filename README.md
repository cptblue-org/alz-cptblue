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

## Create VPN Gateway

### New branch create-vpn-gateway   

~~~bash
# show the current branch
git branch --show-current # should be main
# create branch to change fw sku
git branch create-vpn-gw
# switch to the new branch
git checkout create-vpn-gw
~~~

### Commit and Pull requewst via github cli

~~~bash
terraform fmt
terraform validate
terraform plan -out=tfplan-create-vpn-gw
# get current git status
git status
# commit all your changes
git add .
git commit -m "create-vpn-gw"
git push --set-upstream origin create-vpn-gw
gh pr create --title "create-vpn-gw" --body "create-vpn-gw" --base main
~~~

Approve the pull request and merge it via the web interface.

## Assign RT DINE Policy to MG Online (Work in progress)

### New branch dine-assigment-rt-online

~~~bash
# show the current branch
git branch --show-current # should be main
# create branch to change fw sku
git branch dine-assigment-rt-online
# switch to the new branch
git checkout dine-assigment-rt-online
~~~

Modify the main.tf file to change the firewall sku to basic.

Create new archetype for online_landing_zone
~~~bash
cp lib/archetype_extension_es_landing_zones.tmpl.json lib/archetype_extension_es_online_landing_zones.tmpl.json
# create and modify the new archetype
code lib/archetype_extension_es_online_landing_zones.tmpl.json
# lookup DINE parameters
code .terraform/modules/enterprise_scale/modules/archetypes/lib/policy_definitions/policy_definition_es_deploy_custom_route_table.json
~~~


### Commit and Pull requewst via github cli

~~~bash
terraform init # because of lz vending module
terraform fmt
terraform validate
terraform plan -out=tfplan-dine-assigment-rt-online
terraform show tfplan-dine-assigment-rt-online
# get current git status
git status
# commit all your changes
git add .
git status
git commit -m "dine-assigment-rt-online"
git push --set-upstream origin dine-assigment-rt-online
gh pr create --title "dine-assigment-rt-online" --body "dine-assigment-rt-online" --base main
~~~

Approve the pull request and merge it via the web interface.

# Misc

## Github

We are going to provide some secretes and variables via the github build in secrets and variables feature.
> NOTE: If it comes to secret, this is a best practices, but I am unsure if variable should go into github. It would be better to keep them all at one place. Maybe the bicep parameter files are a better place. But in this case we would need to store resource ids in clear text.
~~~bash
# create github secret via gh cli for repo cptdazlz
gh secret set AZURE_CLIENT_ID -b $appid -e production
tid=$(az account show --query tenantId -o tsv)
gh secret set AZURE_TENANT_ID -b $tid -e production
subid=$(az account show --query id -o tsv)
gh secret set AZURE_SUBSCRIPTION_ID -b $subid -e production
gh secret set AZURE_OBJECT_ID -b $objectid -e production
gh secret list --env production

gh variable set MG_PREFIX -b alz --env production
gh variable set MG_TOPLEVEL_DISPLAYNAME -b "MyEdge Landing Zones" --env production
gh variable set LOCATION_GWC -b "germanywestcentral" --env production
# get log analytics workspace id
lawid=$(az monitor log-analytics workspace show -n alz-log-analytics -g rg-alz-logging-001 --query id -o tsv)
gh variable set LAW_ID_GWC -b $lawid --env production
pDnsRg=$(az group show -n rg-alz-vwan-001 --query id -o tsv)
gh variable set PDNS_RG_ID -b $pDnsRg --env production
gh variable list --env production

az account set -s sub-lz-bootstrap
az ad app federated-credential list --id 77eccaa5-34fc-45a8-98b9-5b7b95c84731
~~~
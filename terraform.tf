terraform {
  required_version = "~> 1.6"
  required_providers {
    azurerm = "~> 3.88"
  }
  backend "azurerm" {
    storage_account_name = "stoalzcptblueger001ytit"
    container_name       = "cptblue-tfstate"
    key                  = "terraform.tfstate"
    use_azuread_auth     = true
    subscription_id      = "49832f1c-479a-4680-9227-0f16c7f51fea"
    tenant_id            = "57ad7d55-bb4d-408b-97ea-198d5023f646"
  }
}

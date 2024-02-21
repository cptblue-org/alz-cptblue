module "enterprise_scale" {
  source  = "Azure/caf-enterprise-scale/azurerm"
  version = "4.2.0"

  disable_telemetry = true

  default_location = var.default_location
  root_parent_id   = data.azurerm_client_config.core.tenant_id

  deploy_corp_landing_zones    = true
  deploy_online_landing_zones  = true
  root_id                      = var.root_id
  root_name                    = var.root_name
  subscription_id_connectivity = var.subscription_id_connectivity
  subscription_id_identity     = var.subscription_id_identity
  subscription_id_management   = var.subscription_id_management

  // Use management group association instead of having to be explicit about MG membership
  strict_subscription_association = false

  // Management resources
  deploy_management_resources = true
  configure_management_resources = {
    settings = {
      log_analytics = {
        config = {
          enable_monitoring_for_arc                         = false
          enable_monitoring_for_vm                          = true
          enable_monitoring_for_vmss                        = true
          enable_sentinel                                   = false
          enable_solution_for_agent_health_assessment       = true
          enable_solution_for_anti_malware                  = true
          enable_solution_for_azure_activity                = true
          enable_solution_for_change_tracking               = true
          enable_solution_for_service_map                   = true
          enable_solution_for_sql_advanced_threat_detection = false
          enable_solution_for_sql_assessment                = false
          enable_solution_for_sql_vulnerability_assessment  = false
          enable_solution_for_updates                       = false
          enable_solution_for_vm_insights                   = true
          retention_in_days                                 = 30
        }
        enabled = true
      }
      security_center = {
        config = {
          email_security_contact = "operator@cptblue.org"
        }
        enabled = true
      }
    }
    tags = null
  }

  // Connectivity (hub network) configuration
  deploy_connectivity_resources = true
  configure_connectivity_resources = {
    settings = {
      dns = {
        config = {
          enable_private_dns_zone_virtual_network_link_on_hubs   = false
          enable_private_dns_zone_virtual_network_link_on_spokes = false
          enable_private_link_by_service = {
            azure_app_configuration_stores       = false
            azure_automation_dscandhybridworker  = false
            azure_automation_webhook             = false
            azure_backup                         = false
            azure_cache_for_redis                = false
            azure_container_registry             = false
            azure_cosmos_db_cassandra            = false
            azure_cosmos_db_gremlin              = false
            azure_cosmos_db_mongodb              = false
            azure_cosmos_db_sql                  = false
            azure_cosmos_db_table                = false
            azure_data_factory                   = false
            azure_data_factory_portal            = false
            azure_data_lake_file_system_gen2     = false
            azure_database_for_mariadb_server    = false
            azure_database_for_mysql_server      = false
            azure_database_for_postgresql_server = false
            azure_event_grid_domain              = false
            azure_event_grid_topic               = false
            azure_event_hubs_namespace           = false
            azure_file_sync                      = false
            azure_iot_hub                        = false
            azure_key_vault                      = false
            azure_kubernetes_service_management  = false
            azure_machine_learning_workspace     = false
            azure_monitor                        = false
            azure_relay_namespace                = false
            azure_search_service                 = false
            azure_service_bus_namespace          = false
            azure_site_recovery                  = false
            azure_sql_database_sqlserver         = false
            azure_synapse_analytics_sql          = false
            azure_synapse_analytics_sqlserver    = false
            azure_web_apps_sites                 = false
            cognitive_services_account           = false
            signalr                              = false
            storage_account_blob                 = true
            storage_account_file                 = false
            storage_account_queue                = false
            storage_account_table                = false
            storage_account_web                  = false
          }
          location               = ""
          private_dns_zones      = []
          private_link_locations = []
          public_dns_zones       = []
        }
      }
    }
  }
  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm.connectivity
    azurerm.management   = azurerm.management
  }
}

module "hubnetworking" {
  source  = "Azure/hubnetworking/azurerm"
  version = "1.1.0"

  hub_virtual_networks = {
    primary-hub = {
      name                        = "vnet-hub-${var.default_location}"
      address_space               = [var.hub_virtual_network_address_prefix]
      location                    = var.default_location
      resource_group_name         = "rg-connectivity-${var.default_location}"
      resource_group_lock_enabled = false
      firewall = {
        subnet_address_prefix            = var.firewall_subnet_address_prefix
        management_subnet_address_prefix = var.firewall_management_subnet_address_prefix
        sku_tier                         = "Basic"
        sku_name                         = "AZFW_VNet"
      }
    }
  }

  providers = {
    azurerm = azurerm.connectivity
  }

  depends_on = [
    module.enterprise_scale
  ]
}

# The landing zone module will be called once per landing_zone_*.yaml file
# in the data directory.
module "lz_vending" {
  source   = "Azure/lz-vending/azurerm"
  version  = "4.0.2" # change this to your desired version, https://www.terraform.io/language/expressions/version-constraints
  for_each = local.landing_zone_data_map

  location = each.value.location

  # subscription variables
  subscription_alias_enabled = false
  # subscription_billing_scope = "/providers/Microsoft.Billing/billingAccounts/7690848/enrollmentAccounts/${each.value.billing_enrollment_account}"
  # subscription_display_name  = each.value.name
  # subscription_alias_name    = each.value.name
  # subscription_workload      = each.value.workload

  # management group association variables
  subscription_management_group_association_enabled = true
  subscription_management_group_id                  = each.value.management_group_id
  subscription_id                                   = each.value.subscription_id

  # virtual network variables
  virtual_network_enabled = true
  virtual_networks = {
    for k, v in each.value.virtual_networks : k => merge(
      v,
      {
        hub_network_resource_id         = local.hub_networks_by_location[each.value.location]
        hub_peering_use_remote_gateways = false
      }
    )
  }
}

# module "virtual_network_gateway" {
#   source  = "Azure/avm-ptn-vnetgateway/azurerm"
#   version = "0.2.0"

#   count = var.virtual_network_gateway_creation_enabled ? 1 : 0

#   location                            = var.default_location
#   name                                = "vgw-hub-${var.default_location}"
#   sku                                 = "VpnGw1"
#   subnet_address_prefix               = var.gateway_subnet_address_prefix
#   type                                = "Vpn"
#   enable_telemetry                    = false
#   virtual_network_name                = module.hubnetworking.virtual_networks["primary-hub"].name
#   virtual_network_resource_group_name = "rg-connectivity-${var.default_location}"

#   providers = {
#     azurerm = azurerm.connectivity
#   }

#   depends_on = [
#     module.hubnetworking
#   ]
# }

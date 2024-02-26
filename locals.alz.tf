locals {
  hub_networks_by_location = {
    for k, v in module.hubnetworking.virtual_networks :
    v.location => v.id
  }
}

locals {
  archetype_config_overrides = {
    landing-zones = {
      archetype_id = "es_landing_zones"
      parameters = {
        Deny-Subnet-Without-Nsg = {
          effect = "Audit"
        }
      }
      access_control = {}
    }
    corp = {
      archetype_id = "es_corp"
      parameters = {
        Deny-Public-Endpoints = {
          ACRPublicIpDenyEffect = "Audit"
        }
      }
      access_control = {}
    }
  }
}

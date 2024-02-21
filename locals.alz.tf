locals {
  hub_networks_by_location = {
    for k, v in module.hubnetworking.virtual_networks :
    v.location => k
  }
}

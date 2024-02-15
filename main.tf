locals {
  workload_name_sanitized = lower(var.workload_name)
  region_name_sanitized   = lower(var.region_name)

  aks_dns_name_prefix                      = "${azurecaf_name.azurerm_kubernetes_cluster_k8s.result}-dns"
  private_cluster_enabled                  = can(var.aks_configuration.private_cluster.enabled) ? var.aks_configuration.private_cluster.enabled : false
  customer_managed_keys_enabled            = can(var.aks_configuration.security_options.enable_self_managed_keys) ? var.aks_configuration.security_options.enable_self_managed_keys : false
  existing_vnet_defined                    = var.network_configuration.vnet_key == null ? false : true
  udr_routing_enabled                      = can(var.network_configuration.egress_configuration.egress_type) ? var.network_configuration.egress_configuration.egress_type == "userDefinedRouting" : false
  app_gateway_enabled                      = can(var.network_configuration.ingress_configuration.app_gateway.subnet_address_space) ? true : false
  use_user_assigned_managed_identity       = !var.aks_configuration.cluster_identity_system_managed
  internal_loadbalancer_enabled            = can(var.network_configuration.ingress_configuration.internal_loadbalancer_enabled) ? var.network_configuration.ingress_configuration.internal_loadbalancer_enabled : false
  provision_managed_prometheus_integration = var.aks_configuration.managed_prometheus != null && var.aks_configuration.managed_prometheus != {}
  #service_mesh_profile_exists        = try(var.aks_configuration.service_mesh_profile != null, false) ? true : false
  #service_mesh_profile_configured    = local.service_mesh_profile_exists && var.aks_configuration.service_mesh_profile.mode != null && var.aks_configuration.service_mesh_profile.mode != "None" ? true : false

  spot_pool_configurations   = { for k, v in var.k8s_spot_pool_configurations : k => v }
  worker_pool_configurations = { for k, v in var.k8s_worker_pool_configurations : k => v }
  security_resource_group    = var.aks_configuration.security_options.security_resource_group_key != null ? var.resource_groups[var.aks_configuration.security_options.security_resource_group_key] : azurerm_resource_group.security[0]
}

data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}

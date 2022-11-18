resource "azurerm_key_vault" "aks_customer_managed_keys_encryption" {
  count = local.customer_managed_keys_enabled ? 1 : 0

  name                        = "kv-${substr(md5(local.aks_name), 0, 16)}-${local.environment_sanitized}"
  resource_group_name         = azurerm_resource_group.security.name
  location                    = azurerm_resource_group.security.location
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "premium"
  enabled_for_disk_encryption = true
  soft_delete_retention_days  = 90
  purge_protection_enabled    = true
  tags = {
    "managedBy" = "${local.aks_name}"
  }

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
  }

  lifecycle {
    ignore_changes = [
      tags,
      network_acls
    ]
  }
}

resource "azurerm_key_vault_access_policy" "aks_customer_managed_keys_encryption_devops_agent" {
  count = local.customer_managed_keys_enabled ? 1 : 0

  key_vault_id = azurerm_key_vault.aks_customer_managed_keys_encryption.0.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  certificate_permissions = [
    "Create",
    "Delete",
    "DeleteIssuers",
    "Get",
    "GetIssuers",
    "Import",
    "List",
    "ListIssuers",
    "ManageIssuers",
    "Purge",
    "Recover",
    "Restore",
    "SetIssuers",
    "Update"
  ]
  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "Import",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Update",
    "Verify"
  ]

  secret_permissions = [
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Set"
  ]
}

resource "azurerm_key_vault_access_policy" "aks_customer_managed_keys_encryption" {
  count = local.customer_managed_keys_enabled ? 1 : 0

  key_vault_id = azurerm_key_vault.aks_customer_managed_keys_encryption.0.id
  tenant_id    = azurerm_disk_encryption_set.aks_customer_managed_key.0.identity.0.tenant_id
  object_id    = azurerm_disk_encryption_set.aks_customer_managed_key.0.identity.0.principal_id

  key_permissions = [
    "Get",
    "WrapKey",
    "UnwrapKey"
  ]
}

resource "azurerm_key_vault_key" "aks_customer_managed_keys_encryption" {
  count = local.customer_managed_keys_enabled ? 1 : 0

  name         = "des-${local.aks_name}"
  key_vault_id = azurerm_key_vault.aks_customer_managed_keys_encryption.0.id
  key_type     = "RSA"
  key_size     = 2048

  depends_on = [
    azurerm_key_vault_access_policy.aks_customer_managed_keys_encryption_devops_agent
  ]

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}
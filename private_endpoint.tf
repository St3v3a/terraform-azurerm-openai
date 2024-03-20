locals {
  private_dns_zone_id   = length(var.private_endpoint) > 0 ? try(azurerm_private_dns_zone.dns_zone[0].id, data.azurerm_private_dns_zone.dns_zone[0].id) : null
  private_dns_zone_name = length(var.private_endpoint) > 0 ? try(azurerm_private_dns_zone.dns_zone[0].name, data.azurerm_private_dns_zone.dns_zone[0].name) : null
}

resource "azurerm_private_endpoint" "this" {
  for_each = var.private_endpoint

  location            = data.azurerm_resource_group.pe_vnet_rg[each.key].location
  name                = each.value.name
  resource_group_name = data.azurerm_resource_group.pe_vnet_rg[each.key].name
  subnet_id           = data.azurerm_subnet.pe_subnet[each.key].id
  tags = merge(local.tags, (/*<box>*/ (var.tracing_tags_enabled ? { for k, v in /*</box>*/ {
    avm_git_commit           = "c8b6b17b0b28a2aa54a3e734b9bd0a0d0ef5c267"
    avm_git_file             = "private_endpoint.tf"
    avm_git_last_modified_at = "2023-05-04 10:08:08"
    avm_git_org              = "Azure"
    avm_git_repo             = "terraform-azurerm-openai"
    avm_yor_trace            = "a1a7ccc1-614f-48ab-8f8a-a1739769872d"
    } /*<box>*/ : replace(k, "avm_", var.tracing_tags_prefix) => v } : {}) /*</box>*/), (/*<box>*/ (var.tracing_tags_enabled ? { for k, v in /*</box>*/ {
    avm_yor_name = "this"
  } /*<box>*/ : replace(k, "avm_", var.tracing_tags_prefix) => v } : {}) /*</box>*/))

  private_service_connection {
    is_manual_connection           = each.value.is_manual_connection
    name                           = each.value.private_service_connection_name
    private_connection_resource_id = azurerm_cognitive_account.this.id
    subresource_names              = var.pe_subresource
  }
  dynamic "private_dns_zone_group" {
    for_each = each.value.private_dns_entry_enabled ? ["private_dns_zone_group"] : []

    content {
      name                 = local.private_dns_zone_name
      private_dns_zone_ids = [local.private_dns_zone_id]
    }
  }
}

data "azurerm_private_dns_zone" "dns_zone" {
  count = length(var.private_endpoint) > 0 && var.private_dns_zone != null ? 1 : 0

  name                = var.private_dns_zone.name
  resource_group_name = var.private_dns_zone.resource_group_name
}

resource "azurerm_private_dns_zone" "dns_zone" {
  count = length(var.private_endpoint) > 0 && var.private_dns_zone == null ? 1 : 0

  name                = "privatelink.openai.azure.com"
  resource_group_name = data.azurerm_resource_group.this.name
  tags = merge(local.tags, (/*<box>*/ (var.tracing_tags_enabled ? { for k, v in /*</box>*/ {
    avm_git_commit           = "0dfe2497a0421d4c7abd975088122ab600ce7c3d"
    avm_git_file             = "private_endpoint.tf"
    avm_git_last_modified_at = "2023-05-09 12:30:19"
    avm_git_org              = "Azure"
    avm_git_repo             = "terraform-azurerm-openai"
    avm_yor_trace            = "63703fb8-62c7-485c-ba41-fc36ca4032d9"
    } /*<box>*/ : replace(k, "avm_", var.tracing_tags_prefix) => v } : {}) /*</box>*/), (/*<box>*/ (var.tracing_tags_enabled ? { for k, v in /*</box>*/ {
    avm_yor_name = "dns_zone"
  } /*<box>*/ : replace(k, "avm_", var.tracing_tags_prefix) => v } : {}) /*</box>*/))
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_link" {
  for_each = var.private_endpoint

  name                  = each.value.dns_zone_virtual_network_link_name
  private_dns_zone_name = local.private_dns_zone_name
  resource_group_name   = data.azurerm_resource_group.this.name
  virtual_network_id    = data.azurerm_virtual_network.vnet[each.key].id
  registration_enabled  = false
  tags = merge(local.tags, (/*<box>*/ (var.tracing_tags_enabled ? { for k, v in /*</box>*/ {
    avm_git_commit           = "c8b6b17b0b28a2aa54a3e734b9bd0a0d0ef5c267"
    avm_git_file             = "private_endpoint.tf"
    avm_git_last_modified_at = "2023-05-04 10:08:08"
    avm_git_org              = "Azure"
    avm_git_repo             = "terraform-azurerm-openai"
    avm_yor_trace            = "5c53ee24-16db-43ae-8ad8-4ed88dd13889"
    } /*<box>*/ : replace(k, "avm_", var.tracing_tags_prefix) => v } : {}) /*</box>*/), (/*<box>*/ (var.tracing_tags_enabled ? { for k, v in /*</box>*/ {
    avm_yor_name = "dns_zone_link"
  } /*<box>*/ : replace(k, "avm_", var.tracing_tags_prefix) => v } : {}) /*</box>*/))
}
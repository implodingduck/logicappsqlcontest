
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.62.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "=3.1.0"
    }
  }
  backend "azurerm" {

  }
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
}

locals {
  func_name = "sctf${random_string.unique.result}"
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "rg-logicapp-sql-con-test"
  location = var.location
}

resource "random_string" "unique" {
  length  = 8
  special = false
  upper   = false
}

module "function" {
    source = "github.com/implodingduck/tfmodules//functionapp"
    func_name = local.func_name
    resource_group_name = azurerm_resource_group.rg.name
    resource_group_location = azurerm_resource_group.rg.location
    working_dir = "SqlConTestFunc"
    app_settings = {
      "FUNCTIONS_WORKER_RUNTIME" = "python"
      "PYODBC_CONNECTOIN_STRING" = "DRIVER={ODBC Driver 17 for SQL Server};SERVER=tcp:${azurerm_mssql_server.db.name}.database.windows.net;PORT=1433;DATABASE=${azurerm_mssql_database.db.name};UID=sqladmin;PWD=${random_password.password.result}"
    }

}

resource "azurerm_key_vault" "kv" {
  name                       = "logappsqlcontest-kv"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled = false

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "create",
      "get",
      "purge",
      "recover",
      "delete"
    ]

    secret_permissions = [
      "set",
      "purge",
      "get",
      "list"
    ]

    certificate_permissions = [
      "purge"
    ]

    storage_permissions = [
      "purge"
    ]
  }
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "azurerm_key_vault_secret" "dbpassword" {
  name         = "dbpassword"
  value        = random_password.password.result
  key_vault_id = azurerm_key_vault.kv.id
  tags         = {}
}

resource "azurerm_mssql_server" "db" {
  name                         = "logicappsqlcontest-server"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = random_password.password.result
  minimum_tls_version          = "1.2"

  tags = {
  }
}

resource "azurerm_mssql_database" "db" {
  name                        = "logicappsqlcontestdb"
  server_id                   = azurerm_mssql_server.db.id
  max_size_gb                 = 40
  auto_pause_delay_in_minutes = -1
  min_capacity                = 1
  sku_name                    = "GP_S_Gen5_1"
  tags = {
  }
  short_term_retention_policy {
    retention_days = 7
  }
}


resource "azurerm_template_deployment" "sql_connection" {
  name = "logicappsqlcontest-sql-connection"
  resource_group_name = azurerm_resource_group.rg.name 

  template_body = <<DEPLOY
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "connections_sql_name": {
            "defaultValue": "sql",
            "type": "String"
        }
    },
    "variables": {},
    "resources": [
        {
            "type": "Microsoft.Web/connections",
            "apiVersion": "2016-06-01",
            "name": "[parameters('connections_sql_name')]",
            "location": "eastus",
            "kind": "V1",
            "properties": {
                "displayName": "logicappsqlcontest-sql-connection",
                "customParameterValues": {},
                "api": {
                    "id": "[concat('/subscriptions/${var.subscription_id}/providers/Microsoft.Web/locations/eastus/managedApis/', parameters('connections_sql_name'))]"
                }
            }
        }
    ]
}
  DEPLOY

  deployment_mode = "Incremental"
}
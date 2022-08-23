terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.19.1"
    }
  }
}

provider "azurerm" {
  features {}
}

# --------------
# Resource Group
# --------------

resource "azurerm_resource_group" "main" {
  name     = "rg-pgg-telcomapp-${var.student_name}"
  location = "West Europe"
}

# ---------------------------
# Cloud Shell Storage Account
# ---------------------------

resource "azurerm_storage_account" "shell" {
  name                     = "sashell${var.student_name}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "share" {
  name                 = "fsshell${var.student_name}"
  storage_account_name = azurerm_storage_account.shell.name
  quota                = 1024
}

# ---------------------
# Media Storage Account
# ---------------------

resource "azurerm_storage_account" "main" {
  name                     = "sapggtelcomapp${var.student_name}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "media" {
  name                 = "audio"
  storage_account_name = azurerm_storage_account.main.name
}

resource "azurerm_storage_container" "txtfiles" {
  name                 = "txtfiles"
  storage_account_name = azurerm_storage_account.main.name
}

resource "azurerm_storage_table" "config" {
  name                 = "config"
  storage_account_name = azurerm_storage_account.main.name
}

resource "azurerm_storage_table_entity" "incident_number" {
  storage_account_name = azurerm_storage_account.main.name
  table_name           = azurerm_storage_table.config.name

  partition_key = "incident_number"
  row_key       = "1"

  entity = {
    value              = 1
    "value@odata.type" = "Edm.Int32"
  }
}

# ---------
# Logic App
# ---------

resource "azurerm_logic_app_integration_account" "main" {
  name                = "ia-telcomapp"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku_name            = "Standard"
}

resource "azurerm_logic_app_workflow" "example" {
  name                = "logic-telcomapp"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  logic_app_integration_account_id = azurerm_logic_app_integration_account.main.id
}

# --------------
# Speech Service
# --------------

resource "azurerm_cognitive_account" "speech_services" {
  name                = "cog-speechservice"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  kind                = "SpeechServices"

  sku_name = "S0"
}

# -----------------------
# Log Analytics Workspace
# -----------------------

resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-telcomapp"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# ------------
# Function App
# ------------

resource "azurerm_storage_account" "function" {
  name                     = "safunctionapp${var.student_name}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "function" {
  name                = "plan-func-telcomapp"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_application_insights" "main" {
  name                = "appi-func-telcomapp"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  application_type    = "web"
}

resource "azurerm_linux_function_app" "example" {
  name                = "func-telcomapp"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  storage_account_name       = azurerm_storage_account.function.name
  storage_account_access_key = azurerm_storage_account.function.primary_access_key
  service_plan_id            = azurerm_service_plan.function.id

  site_config {
    application_insights_key               = azurerm_application_insights.main.instrumentation_key
    application_insights_connection_string = azurerm_application_insights.main.connection_string
  }
}

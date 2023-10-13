terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "high_cpu_usage_on_postgresql_server" {
  source    = "./modules/high_cpu_usage_on_postgresql_server"

  providers = {
    shoreline = shoreline
  }
}
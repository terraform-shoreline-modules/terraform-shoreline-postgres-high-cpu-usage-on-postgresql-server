resource "shoreline_notebook" "high_cpu_usage_on_postgresql_server" {
  name       = "high_cpu_usage_on_postgresql_server"
  data       = file("${path.module}/data/high_cpu_usage_on_postgresql_server.json")
  depends_on = [shoreline_action.invoke_check_connections_limit,shoreline_action.invoke_mem_usage_script,shoreline_action.invoke_change_instance_type]
}

resource "shoreline_file" "check_connections_limit" {
  name             = "check_connections_limit"
  input_file       = "${path.module}/data/check_connections_limit.sh"
  md5              = filemd5("${path.module}/data/check_connections_limit.sh")
  description      = "An increase in the number of incoming requests to the PostgreSQL server, exceeding its processing capacity."
  destination_path = "/tmp/check_connections_limit.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "mem_usage_script" {
  name             = "mem_usage_script"
  input_file       = "${path.module}/data/mem_usage_script.sh"
  md5              = filemd5("${path.module}/data/mem_usage_script.sh")
  description      = "Insufficient memory allocation to the PostgreSQL server, leading to excessive swapping and increased CPU usage."
  destination_path = "/tmp/mem_usage_script.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "change_instance_type" {
  name             = "change_instance_type"
  input_file       = "${path.module}/data/change_instance_type.sh"
  md5              = filemd5("${path.module}/data/change_instance_type.sh")
  description      = "Consider upgrading the server hardware or adding more resources, such as CPU cores or memory, to tackle the high CPU usage."
  destination_path = "/tmp/change_instance_type.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_check_connections_limit" {
  name        = "invoke_check_connections_limit"
  description = "An increase in the number of incoming requests to the PostgreSQL server, exceeding its processing capacity."
  command     = "`chmod +x /tmp/check_connections_limit.sh && /tmp/check_connections_limit.sh`"
  params      = ["MAXIMUM_NUMBER_OF_CONNECTIONS"]
  file_deps   = ["check_connections_limit"]
  enabled     = true
  depends_on  = [shoreline_file.check_connections_limit]
}

resource "shoreline_action" "invoke_mem_usage_script" {
  name        = "invoke_mem_usage_script"
  description = "Insufficient memory allocation to the PostgreSQL server, leading to excessive swapping and increased CPU usage."
  command     = "`chmod +x /tmp/mem_usage_script.sh && /tmp/mem_usage_script.sh`"
  params      = []
  file_deps   = ["mem_usage_script"]
  enabled     = true
  depends_on  = [shoreline_file.mem_usage_script]
}

resource "shoreline_action" "invoke_change_instance_type" {
  name        = "invoke_change_instance_type"
  description = "Consider upgrading the server hardware or adding more resources, such as CPU cores or memory, to tackle the high CPU usage."
  command     = "`chmod +x /tmp/change_instance_type.sh && /tmp/change_instance_type.sh`"
  params      = ["INSTANCE_NAME","REGION_RESOURCE_GROUP_PROJECT_NAME","ZONE_NAME","NEW_INSTANCE_TYPE"]
  file_deps   = ["change_instance_type"]
  enabled     = true
  depends_on  = [shoreline_file.change_instance_type]
}


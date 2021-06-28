terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  version                     = ">= 2.15"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_get_ec2_platforms      = true
  skip_region_validation      = true
  skip_requesting_account_id  = true
  max_retries                 = 1
  access_key                  = "a"
  secret_key                  = "a"
  region                      = "eu-west-1"
}

module "service" {
  source = "../.."

  name             = "test-service"
  task_definition  = "test-taskdef"
  target_group_arn = "arn:aws:elasticloadbalancing:eu-west-1:123456789012:targetgroup/test-service/1234abcd123456ba1"
}

module "service_with_long_name" {
  source = "../.."

  name             = "test-service-humptydumptysatonawallhumptydumptyhadagreatfall"
  task_definition  = "test-taskdef"
  target_group_arn = "arn:aws:elasticloadbalancing:eu-west-1:123456789012:targetgroup/test-service/1234abcd123456ba1"
}

module "service_with_custom_min_and_max_percent" {
  source = "../.."

  name                               = "test-service"
  task_definition                    = "test-taskdef"
  target_group_arn                   = "arn:aws:elasticloadbalancing:eu-west-1:123456789012:targetgroup/test-service/1234abcd123456ba1"
  deployment_minimum_healthy_percent = "0"
  deployment_maximum_percent         = "100"
}

module "no_target_group" {
  source = "../.."

  name            = "test-service"
  task_definition = "test-taskdef"
}

module "service_with_pack_and_distinct_task_placement" {
  source = "../.."

  name             = "test-service"
  task_definition  = "test-taskdef"
  target_group_arn = "arn:aws:elasticloadbalancing:eu-west-1:123456789012:targetgroup/test-service/1234abcd123456ba1"
  pack_and_distinct = "true"
}

module "no_target_group_pack_and_distinct_task_placement" {
  source = "../.."

  name             = "test-service"
  task_definition  = "test-taskdef"
  pack_and_distinct = "true"
}

module "service_with_grace_period" {
  source = "../.."

  name                              = "test-service"
  task_definition                   = "test-taskdef"
  target_group_arn                  = "arn:aws:elasticloadbalancing:eu-west-1:123456789012:targetgroup/test-service/1234abcd123456ba1"
  health_check_grace_period_seconds = "15"
}

module "no_target_group_service_with_grace_period" {
  source = "../.."

  name                              = "test-service"
  task_definition                   = "test-taskdef"
  health_check_grace_period_seconds = "15"
}
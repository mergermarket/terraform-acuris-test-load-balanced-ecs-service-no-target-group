resource "aws_ecs_service" "service" {
  count = var.target_group_arn != "" ? 1 : 0

  name                               = var.name
  cluster                            = var.cluster
  task_definition                    = var.task_definition
  desired_count                      = var.desired_count
  iam_role                           = aws_iam_role.role.arn
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }
  
  ordered_placement_strategy {
    type  = lower(var.pack_and_distinct) == "true" ? "binpack" : "spread"
    field = lower(var.pack_and_distinct) == "true" ? "cpu" : "instanceId"
  }

  placement_constraints {
    type = lower(var.pack_and_distinct) == "true" ? "distinctInstance" : "memberOf"
    expression = lower(var.pack_and_distinct) == "true" ? "" : "agentConnected == true"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      capacity_provider_strategy,
      ordered_placement_strategy,
    ]
  }
}

resource "aws_ecs_service" "service_multiple_loadbalancers" {
  count = var.target_group_arn == "" && length(var.multiple_target_group_arns) > 0 ? 1 : 0

  name                               = var.name
  cluster                            = var.cluster
  task_definition                    = var.task_definition
  desired_count                      = var.desired_count
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds

  dynamic "load_balancer" {
    for_each = var.multiple_target_group_arns
    content {
      target_group_arn = load_balancer.value
      container_name   = var.container_name
      container_port   = var.container_port
    }
  }
  
  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }
  
  ordered_placement_strategy {
    type  = lower(var.pack_and_distinct) == "true" ? "binpack" : "spread"
    field = lower(var.pack_and_distinct) == "true" ? "cpu" : "instanceId"
  }

  placement_constraints {
    type = lower(var.pack_and_distinct) == "true" ? "distinctInstance" : "memberOf"
    expression = lower(var.pack_and_distinct) == "true" ? "" : "agentConnected == true"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      capacity_provider_strategy,
      ordered_placement_strategy,
    ]
  }
}

resource "aws_ecs_service" "service_no_loadbalancer" {
  count = var.target_group_arn == "" && length(var.network_configuration_subnets) == 0 && length(var.multiple_target_group_arns) == 0  ? 1 : 0

  name                               = var.name
  cluster                            = var.cluster
  task_definition                    = var.task_definition
  desired_count                      = var.desired_count
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds

  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }
  
  ordered_placement_strategy {
    type  = lower(var.pack_and_distinct) == "true" ? "binpack" : "spread"
    field = lower(var.pack_and_distinct) == "true" ? "cpu" : "instanceId"
  }

  placement_constraints {
    type = lower(var.pack_and_distinct) == "true" ? "distinctInstance" : "memberOf"
    expression = lower(var.pack_and_distinct) == "true" ? "" : "agentConnected == true"
  }
  
  lifecycle {
    ignore_changes = [
      capacity_provider_strategy,
      ordered_placement_strategy,
    ]
  }
}

resource "aws_ecs_service" "service_for_awsvpc_no_loadbalancer" {
  count = var.target_group_arn == "" && length(var.network_configuration_subnets) > 0 ? 1 : 0

  name                               = var.name
  cluster                            = var.cluster
  task_definition                    = var.task_definition
  desired_count                      = var.desired_count
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds

  network_configuration {
    subnets         = var.network_configuration_subnets
    security_groups = var.network_configuration_security_groups
  }

  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }
  
  ordered_placement_strategy {
    type  = lower(var.pack_and_distinct) == "true" ? "binpack" : "spread"
    field = lower(var.pack_and_distinct) == "true" ? "cpu" : "instanceId"
  }

  placement_constraints {
    type = lower(var.pack_and_distinct) == "true" ? "distinctInstance" : "memberOf"
    expression = lower(var.pack_and_distinct) == "true" ? "" : "agentConnected == true"
  }
  
  lifecycle {
    ignore_changes = [
      capacity_provider_strategy,
      ordered_placement_strategy,
    ]
  }
}

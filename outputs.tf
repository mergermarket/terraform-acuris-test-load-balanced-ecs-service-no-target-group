output "name" {
  value = join(
    "",
    compact(
      concat(
        aws_ecs_service.service.*.name,
        aws_ecs_service.service_no_loadbalancer.*.name,
      )
    )
  )
}

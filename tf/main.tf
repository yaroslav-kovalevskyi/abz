module "networking" {
  source      = "git::https://github.com/yaroslav-kovalevskyi/Terraform.git//modules/networking"
  environment = terraform.workspace
  project     = var.project
  nat_enabled = false
}

module "wordpress" {
  source          = "git::https://github.com/yaroslav-kovalevskyi/Terraform.git//modules/wordpress"
  private_subnets = values(module.networking.private_subnets_properties)[*].id // cannot be inside redis_variables. Map must contain same (or convertible) data type for all values (string / list)
  general = {
    project     = var.project
    domain_name = "kovalevskyi.space"
  }

  vpc_properties = {
    vpc_id     = module.networking.vpc_properties.id
    cidr_block = module.networking.vpc_properties.cidr_block
  }
  db_variables = {
    db_name         = "wordpress"
    engine          = "MySQL"
    identifier      = "${var.project}wordpress"
    instance_class  = "db.t3.micro" // free tier
    master_username = "root"
    storage         = 30
    subnet_group    = module.networking.database_subnet_group_properties.id
  }

  ec2_variables = {
    instance_type    = "t3.micro" // free tier
    public_subnet_id = module.networking.public_subnets_properties[0].id
    wp_admin_email   = "kovalevskyi96@gmail.com"
  }

  redis_variables = {
    cluster_id           = "${var.project}-redis"
    engine_version       = "7.1"
    node_type            = "cache.t3.micro" // free tier
    num_cache_nodes      = 1
    parameter_group_name = "default.redis7"
  }

  wellknown_ip = {
    yk-home = "193.227.206.114/32"
  }
}

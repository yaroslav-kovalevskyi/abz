module "networking" {
  source      = "git::https://github.com/yaroslav-kovalevskyi/Terraform.git//modules/networking"
  environment = terraform.workspace
  project     = var.project
  nat_enabled = false
}

module "wordpress" {
  project     = var.project
  source      = "../../Terraform/modules/wordpress/"
  domain_name = "kovalevskyi.space"
  vpc_id      = module.networking.vpc_properties.id
  db_variables = {
    db_name             = "wordpress"
    engine              = "MySQL"
    identifier          = "${var.project}wordpress"
    instance_class      = "db.t3.micro"
    master_username     = "root"
    publicly_accessible = true
    storage             = 30
    subnet_group        = module.networking.database_subnet_group_properties.id
  }

  ec2_variables = {
    instance_type    = "t3.micro"
    public_subnet_id = module.networking.public_subnets_properties[0].id

  }
  wellknown_ip = {
    YK-home = "193.227.206.114/32"
  }
}

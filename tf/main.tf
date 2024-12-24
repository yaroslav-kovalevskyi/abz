module "networking" {
  source      = "git::https://github.com/yaroslav-kovalevskyi/Terraform.git//modules/networking"
  environment = terraform.workspace
  project     = var.project
  nat_enabled = false
}

module "wordpress" {
  source = "../../Terraform/modules/wordpress/"
  db_variables = {
    storage         = 30
    engine          = "MySQL"
    instance_class  = "db.t3.micro"
    master_username = "root"
  }
}


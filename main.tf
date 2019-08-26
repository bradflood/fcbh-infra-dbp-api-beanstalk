provider "aws" {
  profile = "default"
  region  = var.region
}

module "fcbh_dbp_api_dev_label" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=tags/0.4.0"
  namespace  = "fcbh"
  stage      = "dev"
  name       = "beanstalk"
  attributes = ["public"]
  delimiter  = "-"

  tags = {
    "BusinessUnit" = "FCBH",
    "Snapshot"     = "true"
  }
}



data "aws_availability_zones" "available" {}

module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=tags/0.8.0"
  namespace  = module.fcbh_dbp_api_dev_label.namespace
  stage      = module.fcbh_dbp_api_dev_label.stage
  name       = module.fcbh_dbp_api_dev_label.name
  cidr_block = "10.0.0.0/16"
}


module "subnets" {
  source              = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=tags/0.16.0"
  availability_zones  = ["${slice(data.aws_availability_zones.available.names, 0, var.max_availability_zones)}"]
  namespace           = module.fcbh_dbp_api_dev_label.namespace
  stage               = module.fcbh_dbp_api_dev_label.stage
  name                = module.fcbh_dbp_api_dev_label.name
  region              = var.region
  vpc_id              = module.vpc.vpc_id
  igw_id              = module.vpc.igw_id
  cidr_block          = module.vpc.vpc_cidr_block
  nat_gateway_enabled = "true"
}

module "elastic_beanstalk_application" {
  source      = "git::https://github.com/cloudposse/terraform-aws-elastic-beanstalk-application.git?ref=tags/0.1.6"
  namespace   = module.fcbh_dbp_api_dev_label.namespace
  stage       = module.fcbh_dbp_api_dev_label.stage
  name        = module.fcbh_dbp_api_dev_label.name
  description = "DBP API Beanstalk application"
}

module "elastic_beanstalk_environment" {
  source    = "git::https://github.com/cloudposse/terraform-aws-elastic-beanstalk-environment.git?ref=tags/0.13.0"
  namespace = module.fcbh_dbp_api_dev_label.namespace
  stage     = module.fcbh_dbp_api_dev_label.stage
  name      = module.fcbh_dbp_api_dev_label.name
  zone_id   = var.zone_id
  app       = odule.elastic_beanstalk_application.app_name

  instance_type           = var.instance_type

  loadbalancer_type   = "application"
  vpc_id              = module.vpc.vpc_id
  public_subnets      = module.subnets.public_subnet_ids
  private_subnets     = module.subnets.private_subnet_ids
  security_groups     = [module.vpc.vpc_default_security_group_id]
  solution_stack_name = var.solution_stack_name
  keypair             = ""

  env_vars = "${
    map(
      "ENV1", "Test1",
      "ENV2", "Test2",
      "ENV3", "Test3"
    )
  }"
}


variable "environment" { }
variable "region" { }

variable "state_bucket" { }
variable "state_prefix" { }

variable "instance_type" { }
variable "instance_ssh_key" { }


provider "aws" {
  region = "${var.region}"
}

resource "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "${var.state_bucket}"
    key    = "terraform/${var.environment}/vpc/tfstate"
    region = "${var.region}"
  }
}

module "ami" {
  source = "github.com/terraform-community-modules/tf_aws_ubuntu_ami"
  region = "eu-central-1"
  distribution = "trusty"
  architecture = "amd64"
  virttype = "hvm"
  storagetype = "instance-store"
}

resource "aws_instance" "example" {
  ami             = "${module.ami.ami_id}"
  instance_type   = "${var.instance_type}"
  key_name        = "${var.instance_ssh_key}"
  subnet_id       = "${element(split(",", terraform_remote_state.vpc.output.elb_subnet), 0)}"
  security_groups = ["${terraform_remote_state.vpc.output.default_sg}"]

  root_block_device {

  }

  tags {
    Name  = "${var.state_prefix}"
  }
}
variable "environment" { }
variable "region" { }

variable "state_bucket" { }
variable "state_prefix" { }

variable "instance_ami" { }
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
resource "aws_instance" "example" {
  ami             = "${var.instance_ami}"
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
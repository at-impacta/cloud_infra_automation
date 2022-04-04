locals {
    env = terraform.workspace
}

variable "default_instance_type" {
    default = "t3.xlarge"
}

variable "instance_type" {
    default = {
        dev = "t2.micro"
        qa = "t2.medium"
        prod = "t3.large"
    }
}

variable "max_instance_asg" {
    default = {
        dev = "1"
        qa = "2"
        prod = "4"
    }
}

variable "default_instance_asg" {
    default = "1"
}

output "instance_type" {
    value = contains(keys(var.instance_type), local.env) ? lookup(var.instance, local.env) : var.default_instance_type
}

output "asg" {
    value = contains(keys(var.max_instance_asg), local.env) ? lookup(var.max_instance_asg, local.env) : var.max_instance_asg
}
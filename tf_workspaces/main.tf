#Recebe o nome da workspace
locals {
    env = terraform.workspace
}

locals {
    envs = {
        default = {
            instance_type = "t2.micro"
            ami = "ami-08kjhekjhsdfjja0938"
            region = "us-east-1"
        }
        dev = {
            instance_type = "t2.medium"
            ami = "ami-08kjhekjhsdfjja0938"
            region = "us-east-1"
        }
        qa = {
            instance_type = "t2.xlarge"
            ami = "ami-08kjhekjhsdfjja0938"
            region = "us-east-1"
        }
        prod = {
            instance_type = "t3.large"
            ami = "ami-08kjhekjhsdfjja0938"
            region = "sa-east-1"
        }
    }
    env_vars = contains(keys(local.envs), local.env) ? local.env : "default"
    workspace = merge(local.envs["default"], local.envs[local.env_vars])
}

output "variables" {
    value = local.workspace
}

output "region" {
    value = local.workspace["region"]
}
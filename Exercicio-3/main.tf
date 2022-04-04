module "slackoapp" {
    source = "./modules/slacko-app"
    vpc_id = "VPC_ID"\
    subnet_cidr = "SUBNET_CIDR"
    ssh_key = "SSH_KEY"
    app_name = "APP_NAME"
    app_tags ={
        env = "DEPLOY_ENV"
        project = "PROJECT_NAME"
        customer = "CUSTOMER_NAME"
    }
    app_instance = "t2.micro"
    db_instance = "t2.micro"
}

output "slacko-ip" {
    value = module.slackoapp.slacko-app
}
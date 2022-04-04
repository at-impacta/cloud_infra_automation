data "aws_ami" "slacko-amazon" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_subnet" "slacko-app-sbnet-public" {
    cidr_block = "10.0.102.0/24"
}

resource "aws_key_pair" "slacko-key-ssh" {
    key_name = "slacko-ssh-key"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC6C6L6B4Uh43z4MKuDdfNlq5fMb0CvEEun3Su9Xrd9SNP1pnDZnoq3cQq/+diA81M+15P/aztccmsXDjL1OarJOE6FEim/gYcPmaYIO5G7FjGYosGgy+Yh1/9+J/fGQXG8w2V+a2cx6PA7Bt27YfBrlHPSgjwcZsbHo/vzSTs8B1ZG7YxljVJliORUCNBK1vk3rYyFjlDSFrIXEne5YOsq+KphKkCNokasLtv0C8A1jhMT8tYCogvXcS+4/FnmsAQ1Al3CibwAlLybRISoABvsoHJoywJ4B4/yCgCBHxX4Na63nHv84CdtIxGeIKOtoG8E4n86Ig77/VPbvPi/URyhZj6jVv7SyxPrNuQNMyC2qtFlbEmj7l5PAyN9cFUN1M4hvW4BW4yTkGXBYPIclAg2uTZDmGnzZETV3pBwauoqEyDIBE3gce8Ksk7LBptDWmma6kD9DUGZSH9Eg/JmtEN/+6hmES8L0olbS5kuJAVGfXgcsAfVBZA11qPTRz4+uZ8= slacko"
}

resource "aws_route53_zone" "iaac-zone" {
    name = "iaac.com.br"

    vpc {
        vpc_id = "vpc-0cjdhia8973jdh822"
    }
}

resource "aws_route53_record" "mongodb-dns" {
    zone_id = aws_route53_zone.iaac-zone.zone_id
    name = "mongodb.iaac.com.br"
    type = "A"
    ttl = "300"
    records = [aws_instance.slacko-mongodb.private_ip]
}

data "template_file" "slacko-user-data" {
    template = file("ec2.sh")
    vars = {
        mongodb_server = aws_route53_record.mongodb-dns.name
    }
}

resource "aws_instance" "slacko-app" {
    ami = data.aws_ami.slacko-amazon.id
    instance_type = "t2.micro"
    subnet_id = data.aws_subnet.slacko-app-sbnet-public.id
    associate_public_ip_address = true
    key_name = aws_key_pair.slacko-app-sbnet-public.key_name
    user_data = data.template_file.slacko-user-data.rendered
    tags = {
        Name = "slacko-app"
    }
}

resource "aws_instance" "slacko-mongodb" {
    ami = data.aws_ami.slacko-amazon.id
    instance_type = "t2.small"
    subnet_id = data.aws_subnet.slacko-app-sbnet-public.id
    associate_public_ip_address = true
    key_name = aws_key_pair.slacko-app-sbnet-public.key_name
    user_data = file("mongodb.sh")
    tags = {
        Name = "slacko-mongodb"
    }
}

resource "aws_security_group" "allow-http-ssh" {
    name = "allow_http_ssh"
    description = "Security group to allows SSH and HTTP."
    vpc_id = "vpc-0cjdhia8973jdh822"

    ingress = [
        {
            description = "Allow SSH."
            from_port = 22
            to_port = 22
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
            ipv6_cidr_blocks = ["::/0"]
            prefix_list_ids = []
            security_groups = []
            self = null
        },
        {
            description = "Allow HTTP."
            from_port = 80
            to_port = 80
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
            ipv6_cidr_blocks = ["::/0"]
            prefix_list_ids = []
            security_groups = []
            self = null
        }
    ]

    egress = [
        {
            from_port = 0
            to_port = 0
            protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
            ipv6_cidr_blocks = ["::/0"]
            prefix_list_ids = []
            security_groups = []
            self = null
        }
    ]

    tags = {
        Name = "Allow_SSH_HTTP"
    }
}

resource "aws_network_interface_sg_attachment" "slacko-sg" {
    security_group_id = aws_security_group.allow-http-ssh.id
    network_interface_id = aws_instance.slacko-app.primary_network_interface_id
}

output "slacko-app-ip" {
    value = aws_instance.slacko-app.public_ip
}

output "slacko-mongodb-ip" {
    value = aws_instance.slacko-app.private_ip
}
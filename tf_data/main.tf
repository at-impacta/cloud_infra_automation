data "aws_ami" "amazon2_linux" {
    owners = ["amazon"]
    most_recent = true

    filter {
        name = "name"
        values = ["amzn2-ami*"]
    }

    filter {
        name = "architecture"
        values = ["x86_64"]
    }
}

output image_id {
    value = data.aws_ami.amazon2_linux.id
}
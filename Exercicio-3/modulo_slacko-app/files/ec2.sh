#! /bin/bash
yum update
amazon-linux-extras install docker
service docker start
usermod -a -G docker ec2-user
docker run --restart always -p 80:8000 --env MONGODB_SERVER=${mongodb_server} leonardodg2084/skacko-api:1.1.0
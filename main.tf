provider "aws" {
  region = "${var.aws_region}"
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

resource "aws_security_group" "transmission-sg" {
  name_prefix = "transmission-sg"
  description = "Access Transmission on port 8080"
  vpc_id      = "${var.aws_vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Transmission WebUI"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role_policy" "transmission_box_role_policy" {
  name_prefix = "transmission_box_role_policy_"
  role        = "${aws_iam_role.transmission_box_role.id}"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "RemoteTransmission0",
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "arn:aws:s3:::${var.aws_s3_bucket}/*",
                "arn:aws:s3:::${var.aws_s3_bucket}"
            ]
        }
    ]
}
  EOF
}

resource "aws_iam_role" "transmission_box_role" {
  name_prefix = "transmission_box_role_"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
              "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
  EOF
}

resource "aws_iam_instance_profile" "transmission_box_profile" {
  name_prefix = "transmission_box_profile_"
  role        = "${aws_iam_role.transmission_box_role.name}"
}

resource "aws_instance" "transmission_box" {
  ami                    = "${aws_ami.amazon_linux_2.id}"
  instance_type          = "${var.aws_instance_type}"
  subnet_id              = "${var.aws_subnet_id}"
  vpc_security_group_ids = ["${aws_security_group.transmission-sg.id}"]
  key_name               = "${var.aws_key_name}"
  root_block_device {
    volume_size = 10
  }
  iam_instance_profile = "${aws_iam_instance_profile.transmission_box_profile.name}"
  user_data            = <<EOF
    #!/bin/bash
    yum update -y
    amazon-linux-extras install docker -y
    service docker start
    usermod -a -G docker ec2-user
    mkdir /opt/completed
    docker pull haugene/transmission-openvpn
    docker pull haugene/transmission-openvpn-proxy
    docker pull willdady/go-watch-s3
    docker run -d \
      --cap-add=NET_ADMIN \
      --name my_transmission \
      -v /opt/:/data \
      -v /etc/localtime:/etc/localtime:ro \
      -e CREATE_TUN_DEVICE=true \
      -e OPENVPN_PROVIDER=${var.openvpn_provider} \
      -e "OPENVPN_CONFIG=${var.openvpn_config}" \
      -e OPENVPN_USERNAME=${var.openvpn_username} \
      -e OPENVPN_PASSWORD=${var.openvpn_password} \
      -e WEBPROXY_ENABLED=false \
      -e TRANSMISSION_SPEED_LIMIT_UP_ENABLED=true \
      -e TRANSMISSION_SPEED_LIMIT_UP=10 \
      --log-driver json-file \
      --log-opt max-size=10m \
      haugene/transmission-openvpn
    docker run -d \
      --name my_transmission_proxy \
      --link my_transmission:transmission \
      -p 8080:8080 \
      haugene/transmission-openvpn-proxy
    docker run -d \
      --name my_go_watch_s3 \
      -v /opt/completed:/data \
      -e WATCH_PATH=/data/ \
      -e AWS_REGION=${var.aws_region} \
      -e AWS_S3_BUCKET=${var.aws_s3_bucket} \
      -e PATH_PATTERN=${var.path_pattern} \
      willdady/go-watch-s3
  EOF
}

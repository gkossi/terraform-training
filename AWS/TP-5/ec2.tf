# Configuration du Provider AWS
provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["C:/Users/BORIS/Downloads/aws_credentials"] # Utilisation de share_credenials_files
}

terraform {
  backend "s3" {
    bucket     = "terraform-backend-kossi"
    key        = "tp-5.tfstate"
    region     = "us-east-1"
    #access_key = "PUT YOUR OWN"
    #secret_key = "PUT YOUR OWN"
    shared_credentials_files = ["C:/Users/BORIS/Downloads/aws_credentials"] # Utilisation de share_credenials_files
  }
}

data "aws_ami" "app_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "myec2" {
  ami             = data.aws_ami.app_ami.id
  instance_type   = var.instance_type
  tags            = var.aws_common_tag
  key_name        = "expertdevops" # devops-kossi
  security_groups = ["${aws_security_group.tp5_allow_ssh_http_https.name}"]

  provisioner "remote-exec" {
    inline = [
      "sudo amazon-linux-extras install -y nginx1.12",
      "sudo systemctl start nginx"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("C:/Users/BORIS/Downloads/expertdevops.pem")
      #private_key = file("C:/Users/BORIS/Downloads/devops-kossi.pem")
      host        = self.public_ip
    }
  }
  root_block_device {
    delete_on_termination = true
  }

}

resource "aws_security_group" "tp5_allow_ssh_http_https" {
  name        = "tp5_allow_ssh_http_https" # kossi-sg
  description = "Allow ssh, http and https inbound traffics and all other outbound trafics"

  # Règle pour autoriser le trafic entrant HTTPS (port 80)
  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permettre l'accès de partout
  }

  # Règle pour autoriser le trafic entrant HTTP (port 443)
  ingress {
    description = "http from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permettre l'accès de partout
  }

  # Règle pour autoriser le trafic entrant SSH (port 22)
  ingress {
    description = "ssh from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permettre l'accès de partout
  }

  # Règle pour autoriser tout type de trafic sortant
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_eip" "public-ip" {
  instance = aws_instance.myec2.id
  domain   = "vpc"
  provisioner "local-exec" {
    #command = "echo PUBLIC IP: ${aws_eip.public-ip.public_ip} ; ID: ${aws_instance.myec2.id} ; AZ: ${aws_instance.myec2.availability_zone}; >> infos_ec2.txt"
    command = "echo PUBLIC IP: ${self.public_ip}; ID: ${aws_instance.myec2.id}; AZ: ${aws_instance.myec2.availability_zone} > infos_ec2.txt"
  }
}

# Configuration du Provider AWS
provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["C:/Users/BORIS/Downloads/aws_credentials"] # Utilisation de share_credenials_files
}
/* provider "aws" {
  region     = "us-east-1"
  access_key = "PUT YOUR OWN"
  secret_key = "PUT YOUR OWN"
} */

# Récupération dynamique de l'image à utiliser
data "aws_ami" "app_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

# Configuration de la ressource
resource "aws_instance" "myec2" {
  ami             = data.aws_ami.app_ami.id
  instance_type   = var.instance_type
  tags            = var.aws_common_tag
  key_name        = "expertdevops" # devops-kossi
  security_groups = ["${aws_security_group.tp3_allow_http_https.name}"]
}

resource "aws_security_group" "tp3_allow_http_https" {
  name        = "tp3_allow_http_https"
  description = "Allow http and https inbound traffic"

  # Règle pour autoriser le trafic entrant HTTP (port 80)
  ingress {
    description = "http from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permettre l'accès de partout
  }

  # Règle pour autoriser le trafic entrant HTTPS (port 443)
  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permettre l'accès de partout
  }
}

#EIP
resource "aws_eip" "public-ip" {
  instance = aws_instance.myec2.id
  domain   = "vpc"
}

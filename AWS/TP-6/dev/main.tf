# Configuration du Provider AWS
provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["C:/Users/BORIS/Downloads/aws_credentials"] # Utilisation de share_credenials_files
}

# Configuration du backend s3
terraform {
  backend "s3" {
    bucket     = "terraform-backend-kossi"
    key        = "tp6-dev.tfstate"
    region     = "us-east-1"
    shared_credentials_files = ["C:/Users/BORIS/Downloads/aws_credentials"] # Utilisation de share_credenials_files
  }
}

# Appel du module ec2
module "ec2" {
  source       = "../modules/ec2module" # Définition de la source du module

  # Surcharge des différentes variables définies dans le module
  instance_type = "t2.nano"

  aws_common_tag = {
    Name = "ec2-dev-kossi"
  }
  
  sg_name = "dev-sg-kossi"
}

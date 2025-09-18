// Configura o provedor AWS e a região
provider "aws" {
  region = "us-east-1"
}

// Configura o backend S3 para armazenar o arquivo de estado do Terraform
terraform {
  backend "s3" {
    bucket = "sqibidi-123456789" // <-- ATUALIZE AQUI
    key    = "global/s3/terraform.tfstate"
    region = "us-east-1"
  }
}

// Busca a AMI mais recente da Amazon Linux 2
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

// Define o grupo de segurança para a instância
resource "aws_security_group" "security_group" {
  name        = "app-security-group"
  description = "Permitir HTTP, HTTPS e SSH"

  // Libera acesso na porta 80 (HTTP - Frontend)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Libera acesso na porta 443 (HTTPS - Futuro)
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Libera acesso na porta 22 (SSH) - RECOMENDAÇÃO: Troque "0.0.0.0/0" pelo seu IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Libera todo o tráfego de saída
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// Cria a instância EC2
resource "aws_instance" "servidor_app" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.micro" // t2.micro é garantido no Free Tier
  user_data              = file("user_data.sh")
  key_name               = "sqibidi-app" // <-- ATUALIZE com o nome da chave que você criou na AWS
  vpc_security_group_ids = [aws_security_group.security_group.id]

  tags = {
    Name = "Servidor-Aplicacao"
  }
}

// Cria uma saída para exibir o IP público da instância após a criação
output "instance_public_ip" {
  value = aws_instance.servidor_app.public_ip
}

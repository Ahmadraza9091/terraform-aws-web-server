
provider "aws" {
  region = "us-east-1"
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to SSH to the web server"
  type        = string
  default     = "0.0.0.0/0"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow HTTP and SSH traffic"
  vpc_id      = aws_vpc.main.id

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  # Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web_sg"
  }
}

resource "aws_instance" "web" {
  ami                         = "ami-0b6d9d3d33ba97d99"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  # AWS EC2 Key Pair
  key_name = "linux_practice"

  user_data = <<-EOF
    #!/bin/bash
    set -euo pipefail

    if command -v apt-get >/dev/null 2>&1; then
      apt-get update
      DEBIAN_FRONTEND=noninteractive apt-get install -y apache2
      service_name=apache2
    elif command -v dnf >/dev/null 2>&1; then
      dnf install -y httpd
      service_name=httpd
    elif command -v yum >/dev/null 2>&1; then
      yum install -y httpd
      service_name=httpd
    else
      echo "No supported package manager found" >&2
      exit 1
    fi

    install -d /var/www/html
    printf '%s' '${base64gzip(file("${path.module}/index.html"))}' | base64 --decode | gzip --decompress > /var/www/html/index.html
    systemctl enable --now "$service_name"
  EOF

  tags = {
    Name = "Ubuntu-WebServer"
  }
}

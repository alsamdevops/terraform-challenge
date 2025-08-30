provider "aws" {
  region = "us-east-1"
}

# =========================
# Amazon Linux VM
# =========================
resource "aws_instance" "amazon_linux" {
  ami                    = "ami-0a232144cf20a27a5" # Amazon Linux 2 AMI
  instance_type          = "t2.micro"
  key_name               = "new"
  associate_public_ip_address = true

  tags = {
    Name = "c8.local"
  }

  user_data = <<-EOF
              #!/bin/bash
              hostnamectl set-hostname c8.local
              echo "127.0.0.1   c8.local" >> /etc/hosts
              EOF

  provisioner "local-exec" {
    command = "echo '[frontend]\nc8.local ansible_host=${self.public_ip} ansible_user=ec2-user' > inventory_part_frontend"
  }
}

# =========================
# Ubuntu 21.04 VM
# =========================
resource "aws_instance" "ubuntu" {
  ami                    = "ami-0bbdd8c17ed981ef9" # Ubuntu 21.04 AMI
  instance_type          = "t2.micro"
  key_name               = "new"
  associate_public_ip_address = true

  tags = {
    Name = "u21.local"
  }

  user_data = <<-EOF
              #!/bin/bash
              hostnamectl set-hostname u21.local
              echo "127.0.0.1   u21.local" >> /etc/hosts
              EOF

  provisioner "local-exec" {
    command = "echo '[backend]\nu21.local ansible_host=${self.public_ip} ansible_user=ubuntu' > inventory_part_backend"
  }
}

# =========================
# Merge inventory
# =========================
resource "null_resource" "merge_inventory" {
  depends_on = [aws_instance.amazon_linux, aws_instance.ubuntu]

  provisioner "local-exec" {
    command = "cat inventory_part_frontend inventory_part_backend > hosts.ini"
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

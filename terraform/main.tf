provider "aws" {
  region = "us-east-1"
}

# =========================
# Amazon Linux VM
# =========================
resource "aws_instance" "amazon_linux" {
  ami                    = "ami-0a232144cf20a27a5" # Amazon Linux 2
  instance_type          = "t2.micro"
  key_name               = "new" # AWS Key Pair name
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
    command = <<EOT
      echo "[frontend]" > inventory_part_frontend
      echo "c8.local ansible_host=${self.public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=jenkins/.ssh/new.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> inventory_part_frontend
    EOT
  }
}

# =========================
# Ubuntu 21.04 VM
# =========================
resource "aws_instance" "ubuntu" {
  ami                    = "ami-0bbdd8c17ed981ef9" # Ubuntu 21.04
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
    command = <<EOT
      echo "[backend]" > inventory_part_backend
      echo "u21.local ansible_host=${self.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=jenkins/.ssh/new.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> inventory_part_backend
    EOT
  }
}

# =========================
# Merge inventory
# =========================
resource "null_resource" "merge_inventory" {
  depends_on = [aws_instance.amazon_linux, aws_instance.ubuntu]

  provisioner "local-exec" {
    command = <<EOT
      sleep 60
      cat inventory_part_frontend inventory_part_backend > hosts.ini
      echo "Inventory generated: hosts.ini"
    EOT
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

resource "aws_instance" "ec2" {
  ami                         = "ami-0fef201115eefe936"
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet
  vpc_security_group_ids      = [var.sg_id]
  associate_public_ip_address = true
  key_name                    = var.key_name
  user_data_replace_on_change = true
  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }
  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y docker git httpd
              systemctl enable --now docker
              usermod -aG docker ec2-user
              echo "<h1>ITMLab $(hostname -f)</h1>" > /var/www/html/index.html
              systemctl enable --now httpd
              EOF
  tags      = { Name = "DEV-${terraform.workspace}" }
}

output "ec2_ip" { value = aws_instance.ec2.public_ip }
output "instance_id" { value = aws_instance.ec2.id }
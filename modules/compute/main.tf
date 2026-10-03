resource "aws_instance" "ec2" {
  count                       = length(var.public_subnets)
  ami                         = "ami-0fef201115eefe936"
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnets[count.index]
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
              TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
              AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)
              echo "<h1>ITMLab $(hostname -f) - AZ: $AZ</h1>" > /var/www/html/index.html
              systemctl enable --now httpd
              EOF
  tags      = { Name = "DEV-${terraform.workspace}-${count.index}" }
}

output "ec2_ips" { value = aws_instance.ec2[*].public_ip }
output "instance_ids" { value = aws_instance.ec2[*].id }
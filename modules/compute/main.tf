############### AMI ###############

# Amazon Linux 2023 más reciente, publicada por AWS en SSM
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

############### Token del clúster ###############

resource "random_password" "k3s_token" {
  length  = 48
  special = false
}

############### Master (Control Plane) ###############

resource "aws_eip" "master" {
  domain = "vpc"
  tags   = { Name = "EIP-Master-${terraform.workspace}" }
}

resource "aws_instance" "master" {
  ami                         = data.aws_ssm_parameter.al2023.insecure_value
  instance_type               = var.master_instance_type
  subnet_id                   = var.public_subnet
  vpc_security_group_ids      = [var.master_sg_id]
  associate_public_ip_address = true
  key_name                    = var.key_name
  iam_instance_profile        = var.instance_profile
  user_data_replace_on_change = true

  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }
  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }
  user_data = templatefile("${path.module}/templates/master.sh.tftpl", {
    k3s_version = var.k3s_version
    k3s_token   = random_password.k3s_token.result
    public_ip   = aws_eip.master.public_ip
    efs_id      = var.efs_id
    efs_chart   = var.efs_csi_chart_version
  })
  tags = { Name = "Master-${terraform.workspace}" }

  lifecycle { ignore_changes = [ami] }
}

resource "aws_eip_association" "master" {
  instance_id   = aws_instance.master.id
  allocation_id = aws_eip.master.id
}

############### Worker ###############

resource "aws_instance" "worker" {
  ami                         = data.aws_ssm_parameter.al2023.insecure_value
  instance_type               = var.worker_instance_type
  subnet_id                   = var.private_subnet
  vpc_security_group_ids      = [var.worker_sg_id]
  associate_public_ip_address = false
  key_name                    = var.key_name
  iam_instance_profile        = var.instance_profile
  user_data_replace_on_change = true
  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }
  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }
  user_data = templatefile("${path.module}/templates/worker.sh.tftpl", {
    k3s_version = var.k3s_version
    k3s_token   = random_password.k3s_token.result
    master_ip   = aws_instance.master.private_ip
  })
  tags = { Name = "Worker-${terraform.workspace}" }
  lifecycle { ignore_changes = [ami] }
}

output "master_public_ip" { value = aws_eip.master.public_ip }
output "master_private_ip" { value = aws_instance.master.private_ip }
output "worker_private_ip" { value = aws_instance.worker.private_ip }
output "worker_id" { value = aws_instance.worker.id }
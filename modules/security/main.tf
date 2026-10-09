############### Master (Control Plane) ###############

resource "aws_security_group" "master" {
  name   = "SG-Master-${terraform.workspace}"
  vpc_id = var.vpc_id
  tags   = { Name = "SG-Master-${terraform.workspace}" }
}

resource "aws_vpc_security_group_ingress_rule" "master_ssh_admin" {
  security_group_id = aws_security_group.master.id
  description       = "SSH desde admin"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = var.admin_cidr
}

resource "aws_vpc_security_group_ingress_rule" "master_api_admin" {
  security_group_id = aws_security_group.master.id
  description       = "API de Kubernetes desde admin (kubectl)"
  ip_protocol       = "tcp"
  from_port         = 6443
  to_port           = 6443
  cidr_ipv4         = var.admin_cidr
}

resource "aws_vpc_security_group_ingress_rule" "master_api_worker" {
  security_group_id            = aws_security_group.master.id
  description                  = "API de Kubernetes desde workers"
  ip_protocol                  = "tcp"
  from_port                    = 6443
  to_port                      = 6443
  referenced_security_group_id = aws_security_group.worker.id
}

resource "aws_vpc_security_group_ingress_rule" "master_flannel_worker" {
  security_group_id            = aws_security_group.master.id
  description                  = "Flannel VXLAN desde workers"
  ip_protocol                  = "udp"
  from_port                    = 8472
  to_port                      = 8472
  referenced_security_group_id = aws_security_group.worker.id
}

resource "aws_vpc_security_group_ingress_rule" "master_kubelet_worker" {
  security_group_id            = aws_security_group.master.id
  description                  = "Kubelet desde workers (metrics-server)"
  ip_protocol                  = "tcp"
  from_port                    = 10250
  to_port                      = 10250
  referenced_security_group_id = aws_security_group.worker.id
}

resource "aws_vpc_security_group_egress_rule" "master_all" {
  security_group_id = aws_security_group.master.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

output "master_sg_id" { value = aws_security_group.master.id }

############### Worker ###############

resource "aws_security_group" "worker" {
  name   = "SG-Worker-${terraform.workspace}"
  vpc_id = var.vpc_id
  tags   = { Name = "SG-Worker-${terraform.workspace}" }
}

resource "aws_vpc_security_group_ingress_rule" "worker_ssh_master" {
  security_group_id            = aws_security_group.worker.id
  description                  = "SSH desde el master (jump host)"
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  referenced_security_group_id = aws_security_group.master.id
}

resource "aws_vpc_security_group_ingress_rule" "worker_http_alb" {
  security_group_id            = aws_security_group.worker.id
  description                  = "HTTP desde el ALB hacia Traefik"
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
  referenced_security_group_id = aws_security_group.alb.id
}

resource "aws_vpc_security_group_ingress_rule" "worker_flannel_master" {
  security_group_id            = aws_security_group.worker.id
  description                  = "Flannel VXLAN desde el master"
  ip_protocol                  = "udp"
  from_port                    = 8472
  to_port                      = 8472
  referenced_security_group_id = aws_security_group.master.id
}

resource "aws_vpc_security_group_ingress_rule" "worker_kubelet_master" {
  security_group_id            = aws_security_group.worker.id
  description                  = "Kubelet desde el master (logs, exec)"
  ip_protocol                  = "tcp"
  from_port                    = 10250
  to_port                      = 10250
  referenced_security_group_id = aws_security_group.master.id
}

# Entre workers, por si se agregan más nodos
resource "aws_vpc_security_group_ingress_rule" "worker_flannel_self" {
  security_group_id            = aws_security_group.worker.id
  description                  = "Flannel VXLAN entre workers"
  ip_protocol                  = "udp"
  from_port                    = 8472
  to_port                      = 8472
  referenced_security_group_id = aws_security_group.worker.id
}

resource "aws_vpc_security_group_ingress_rule" "worker_kubelet_self" {
  security_group_id            = aws_security_group.worker.id
  description                  = "Kubelet entre workers"
  ip_protocol                  = "tcp"
  from_port                    = 10250
  to_port                      = 10250
  referenced_security_group_id = aws_security_group.worker.id
}

resource "aws_vpc_security_group_egress_rule" "worker_all" {
  security_group_id = aws_security_group.worker.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

output "worker_sg_id" { value = aws_security_group.worker.id }

############### ALB ###############

resource "aws_security_group" "alb" {
  name   = "SG-ALB-${terraform.workspace}"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "SG-ALB-${terraform.workspace}" }
}

output "alb_sg_id" { value = aws_security_group.alb.id }

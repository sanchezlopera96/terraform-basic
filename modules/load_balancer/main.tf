resource "aws_lb" "main" {
  name               = "ALB-${terraform.workspace}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnets
  tags               = { Name = "ALB-${terraform.workspace}" }
}

############### Puerto 80 -> Traefik (Ingress: eventosvivos) ###############

resource "aws_lb_target_group" "tg" {
  name     = "TG-${terraform.workspace}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  # Traefik responde 404 en "/" mientras no exista un Ingress; se acepta para que el target quede healthy
  health_check {
    path     = "/"
    interval = 30
    matcher  = "200-404"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_lb_target_group_attachment" "worker_attach" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = var.worker_instance_id
}

############### Puerto n8n -> NodePort de n8n en el worker ###############

resource "aws_lb_target_group" "n8n" {
  name     = "TG-n8n-${terraform.workspace}"
  port     = var.n8n_node_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  # Mientras n8n no esté desplegado el target queda unhealthy; es esperado
  health_check {
    path     = "/healthz"
    interval = 30
    matcher  = "200"
  }
}

resource "aws_lb_listener" "n8n" {
  load_balancer_arn = aws_lb.main.arn
  port              = var.n8n_public_port
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.n8n.arn
  }
}

resource "aws_lb_target_group_attachment" "n8n_worker" {
  target_group_arn = aws_lb_target_group.n8n.arn
  target_id        = var.worker_instance_id
}

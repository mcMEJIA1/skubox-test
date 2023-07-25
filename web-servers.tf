resource "aws_vpc" "vpc_example" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "SkyBox-VPC"
  }
}

resource "aws_subnet" "sky_subnet" {
  vpc_id            = aws_vpc.vpc_example
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "SkyBox-subnet"
  }
}

resource "aws_security_group" "sky_sg" {
  description = "allow HTTP"
  vpc_id = aws_vpc.vpc_example

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ aws_vpc.vpc_example.cidr_block ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Sky-SG"
  }
}

resource "aws_instance" "server" {
  count         = var.servers_number
  ami           = data.amz-linux.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.sky_subnet.id

  user_data = <<EOF
#!/bin/bash
yum install httpd -y
/sbin/chkconfig --levels 235 httpd on
service httpd start
instanceId=$(curl http://169.254.169.254/latest/meta-data/instance-id)
region=$(curl http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}')
echo "<h1>Hello from web-server-$instanceId</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name = "Web Server"
  }
}

resource "aws_lb" "servers_balancer" {
  name = "SkyBox-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = []
  subnets = [aws_subnet.sky_subnet]
  
  enable_deletion_protection = true

  tags = {
    Name = "SkyBox-application load balancer"
  }
}

resource "aws_lb_target_group" "servers_group" {
  name = "SkyBox-target-group"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.vpc_example.id

  health_check {
    path = "/"
    port = 80
    healthy_threshold = 6
    unhealthy_threshold = 3
    timeout = 3
    interval = 5
    matcher = "200"
  }
}

resource "aws_lb_target_group_attachment" "servers_attachment" {
  count            = length(aws_instance.server)
  target_group_arn = aws_lb_target_group.servers_group
  target_id        = aws_instance.server[count.index].id
  port             = 80
}

resource "aws_lb_listener" "listener" {
  default_action {
    target_group_arn = aws_lb_target_group.servers_group.arn
    type             = "forward" 
  }

  load_balancer_arn = aws_lb.servers_balancer.arn
  port              = 80
  protocol          = "HTTP"
}
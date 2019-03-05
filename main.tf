variable "key_path" { 
  
  default = "/users/rehanbaig/.ssh/id_rsa.pub"
  }

variable "localip" {

  default = "192.168.1.0"
}
  



provider "aws" {
  region  = "us-east-1"
  profile = "rehan"
  }

 resource "aws_key_pair" "rehan1" {
    key_name   = "rehan1"
    public_key = "${file(var.key_path)}"
    }


  resource "aws_security_group" "rehan_sg" {
    name        = "wp_dev_sg"
    description = "Used for access to the dev instance"


  #SSH

    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.localip}"]
    
 
    }

  #HTTP

    ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }
    }

  resource "aws_instance" "rehan-demo" {
    instance_type = "t2.micro"
    ami           = "ami-02da3a138888ced85"
    vpc_security_group_ids = ["${aws_security_group.rehan_sg.id}"]
    key_name = "${aws_key_pair.rehan1.id}"
    user_data = <<-EOF
    #!/bin/bash
    sudo yum install -y httpd 2> var/log/error1.txt
    sudo service httpd restart 2> var/log/error2.txt
    sudo echo "<html><head><title>Hello World</title></head><body><h1>Hello World!</h1></body></html>" > /var/www/html/index.html
  
    EOF

    tags {
    Name = "rehan-demo"
    }
  
  
    }

    resource "aws_elb" "wp_elb" {
  name = "rehan-elb"

  subnets = ["${aws_subnet.wp_public1_subnet.id}",
    "${aws_subnet.wp_public2_subnet.id}",
  ]

  security_groups = ["${aws_security_group.wp_public_sg.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = "${var.elb_healthy_threshold}"
    unhealthy_threshold = "${var.elb_unhealthy_threshold}"
    timeout             = "${var.elb_timeout}"
    target              = "TCP:80"
    interval            = "${var.elb_interval}"
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    Name = "wp_${var.domain_name}-elb"
  }
}


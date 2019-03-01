variable "key_path" { 
  
  default = "/users/rehanbaig/.ssh/id_rsa.pub"
  }

variable "localip" {

  default = "192.168.0.0"
}
  



provider "aws" {
  region  = "us-east-1"
  profile = "rehan"
  }

 resource "aws_key_pair" "wipro1" {
    key_name   = "wipro1"
    public_key = "${file(var.key_path)}"
    }


  resource "aws_security_group" "wipro_sg" {
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

  resource "aws_instance" "wipro-demo" {
    instance_type = "t2.micro"
    ami           = "ami-02da3a138888ced85"
    vpc_security_group_ids = ["${aws_security_group.wipro_sg.id}"]
    key_name = "${aws_key_pair.wipro1.id}"
    user_data = <<-EOF
    #!/bin/bash
    sudo yum install -y httpd 2> var/log/error1.txt
    sudo service httpd restart 2> var/log/error2.txt
    sudo echo "<html><head><title>Hello World</title></head><body><h1>Hello World!</h1></body></html>" > /var/www/html/index.html
  
    EOF

    tags {
    Name = "wipro-demo"
    }
  
  
    }


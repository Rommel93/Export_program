provider "aws" {
	region     = "us-east-1"
}

#Variables
variable "port" {
  description = "The port the server will use"
  default = 80
}
variable "protocol" {
  description = "The protocol used"
  default = HTTP
}

#Resources
#VPC
resource "aws_vpc" "vpc_export" {


tags {
	Name = "Vpc-Export"
}

}

#Route
resource "aws_route" "route_export" {


tags {
	Name = "Route-Export"
}

}

#Subnet
resource "aws_subnet" "subnet_export" {


tags {
	Name = "Subnet-Export"
}

}

#App Server
resource "aws_instance" "app_server" {
        ami = "ami-53b7152e"
        instance_type = "t2.micro"
        availability_zone = "us-east-1a"

 tags {
		Name = "App_Server-Export"
 }
}

#DB Server
resource "aws_db_instance" "db_server" {

 tags {
		Name = "App_Server-Export"
 }
}

#Launch Configuration
resource "aws_launch_configuration" "web_launch_conf" {
  image_id      = ""
  instance_type = ""

tags {
		Name = "Launchcfg-Export"
	}

	}

#Auto Scaling Group
	resource "aws_autoscaling_group" "webserver_asg" {
  name                 = "terraform-asg-example"
  launch_configuration = "${aws_launch_configuration.web_launch_conf.name}"

 tags {
		Name = "ASG-Export"
	}

}

#Load Balancer
resource "aws_lb" "webserver" {
  # ...
}

resource "aws_lb_target_group" "webserver" {
		name     = "tf-example-lb-tg"
		port     = "${var.port}"
		protocol = "${var.protocol}"
		vpc_id   = "${aws_vpc.vpc_export.id}"
}

resource "aws_lb_listener" "webserver_elb" {
		load_balancer_arn = "${aws_lb.webserver.arn}"
		port = "${var.port}"
		protocol = "${var.protocol}"

 tags {
		Name = "Elb-Export"
	}

}
#Security Groups
#Webserver Security Group
resource "aws_security_group" "webserver_group" {

tags {
		Name = "WebserverSG-Export"
	}
}

#App Server Security Group
resource "aws_security_group" "appserver_group" {

tags {
		Name = "AppserverSG-Export"
	}
}

#DB Security Group
resource "aws_security_group" "dbserver_group" {

tags {
		Name = "DBserveSG-Export"
	}
}

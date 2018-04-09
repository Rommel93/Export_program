provider "aws" {
	region     = "us-east-1"
}

resource "aws_vpc" "vpc_export" {
tags {
	Name = "Vpc-Export"
}

}

resource "aws_subnet" "subnet_export" {
tags {
	Name = "Subnet-Export"
}

}

resource "aws_instance" "app_server" {
        ami = "ami-53b7152e"
        instance_type = "t2.micro"
        availability_zone = "us-east-1a"

 tags {
		Name = "App_Server-Export"
 }
}


resource "aws_db_instance" "db_server" {

 tags {
		Name = "App_Server-Export"
 }
}

resource "aws_launch_configuration" "web_launch_conf" {
  image_id      = ""
  instance_type = ""

tags {
		Name = "Launchcfg-Export"
	}

	}

	resource "aws_autoscaling_group" "webserver_asg" {
  name                 = "terraform-asg-example"
  launch_configuration = "${aws_launch_configuration.web_launch_conf.name}"

 tags {
		Name = "ASG-Export"
	}

}

resource "aws_lb_listener" "webserver_elb" {

 tags {
		Name = "Elb-Export"
	}

}

resource "aws_security_group" "webserver_group" {

tags {
		Name = "WebserverSG-Export"
	}
}

resource "aws_security_group" "appserver_group" {

tags {
		Name = "AppserverSG-Export"
	}
}

resource "aws_security_group" "dbserver_group" {

tags {
		Name = "DBserveSG-Export"
	}
}

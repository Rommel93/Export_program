provider "aws" {
	access_key = "${var.aws_access_key}"
	secret_key = "${var.aws_secret_key}"
	region     = "us-east-1"
}

#Resources
#VPC
resource "aws_vpc" "vpc_export" {
		cidr_block = "${var.vpc_cidr}"
		enable_dns_hostnames = true

tags {
	Name = "Vpc-Export"
}

}

#Gateway
resource "aws_internet_gateway" "gw_export" {
    vpc_id = "${aws_vpc.vpc_export.id}"
}

#Nat
resource "aws_security_group" "nat" {
    name = "vpc_nat"
    description = "Allow traffic to pass from the private subnet to the internet"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr}"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }
    egress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.vpc_export.id}"

    tags {
        Name = "NATSG"
    }
}

#Public Subnet
resource "aws_subnet" "us-east-1a-public" {
    vpc_id = "${aws_vpc.vpc_export.id}"

    cidr_block = "${var.public_subnet_cidr}"
    availability_zone = "us-east-1a"

    tags {
        Name = "Public Subnet"
    }
}

resource "aws_route_table" "us-east-1a-public" {
    vpc_id = "${aws_vpc.vpc_export.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.gw_export.id}"
    }

    tags {
        Name = "Public Subnet"
    }
}

resource "aws_route_table_association" "us-east-1a-public" {
    subnet_id = "${aws_subnet.us-east-1a-public.id}"
    route_table_id = "${aws_route_table.us-east-1a-public.id}"
}


#Private Subnet
resource "aws_subnet" "us-east-1a-private" {
    vpc_id = "${aws_vpc.vpc_export.id}"
    cidr_block = "${var.private_subnet_cidr}"
    availability_zone = "us-east-1a"

    tags {
        Name = "Private Subnet"
    }
}
resource "aws_route_table" "us-east-1a-private" {
    vpc_id = "${aws_vpc.vpc_export.id}"

    route {
        cidr_block = "0.0.0.0/0"
#####   instance_id = "${aws_instance.nat.id}"
    }

    tags {
        Name = "Private Subnet"
    }
}

resource "aws_route_table_association" "us-east-1a-private" {
    subnet_id = "${aws_subnet.us-east-1a-private.id}"
    route_table_id = "${aws_route_table.us-east-1a-private.id}"
}


#App Server
resource "aws_instance" "app_server" {
        ami = "${var.amis}"
        instance_type = "${var.instance_type}"
					security_groups			 = ["${aws_security_group.appserver_group.name}"]

 tags {
		Name = "App_Server-Export"
 }
}

#DB Server
resource "aws_db_instance" "db_server" {
	allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "${var.dbname}"
  username             = "${var.dbuser}"
  password             = "${var.dbpass}"
	db_subnet_group_name = "${aws_subnet.us-east-1a-private.id}"
	security_group_names = ["${aws_security_group.dbserver_group.name}"]
 tags {
		Name = "DB_Server-Export"
 }
}

#Launch Configuration
resource "aws_launch_configuration" "web_launch_conf" {
	name          = "web_config"
  image_id      = "${var.amis}"
  instance_type = "${var.instance_type}"
	key_name			= "${var.key}"


	}

#Auto Scaling Group
	resource "aws_autoscaling_group" "webserver_asg" {
  name                 = "terraform-asg-example"
	max_size                  = 2
	min_size                  = 1
	health_check_grace_period = 300
	health_check_type         = "EC2"
	desired_capacity          = 1
  launch_configuration      = "${aws_launch_configuration.web_launch_conf.name}"
  vpc_zone_identifier       = ["${aws_subnet.us-east-1a-public.id}"]
	load_balancers						= ["${aws_elb.webserver.name}"]

 tags {
		Name = "ASG-Export"
	}

}

#Load Balancer
resource "aws_elb" "webserver" {
	name               	= "ELBexport"
  availability_zones 	= ["us-east-1a"]
	security_groups 		= ["${aws_security_group.dbserver_group.name}"]

	listener {
    instance_port     = "${var.port}"
    instance_protocol = "${var.protocol}"
    lb_port           = "${var.port}"
    lb_protocol       = "${var.protocol}"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }


 tags {
		Name = "Elb-Export"
	}

}

#Security Groups
#Webserver Security Group
resource "aws_security_group" "webserver_group" {

name        = "webserversg"
description = "Allow Ports 80 and 22"
vpc_id      = "${aws_vpc.vpc_export.id}"

ingress {
		 from_port = 80
		 to_port = 80
		 protocol = "tcp"
		 cidr_blocks = ["0.0.0.0/0"]
}

ingress {
		 from_port = 22
		 to_port = 22
		 protocol = "tcp"
		 cidr_blocks = ["0.0.0.0/0"]
}

tags {
		Name = "WebserverSG-Export"
	}
}

#App Server Security Group
resource "aws_security_group" "appserver_group" {

name        = "appserversg"
description = "Allow Ports 9043 and 22"
vpc_id      = "${aws_vpc.vpc_export.id}"

ingress {
		 from_port = 9043
		 to_port = 9043
		 protocol = "tcp"
		 cidr_blocks = ["0.0.0.0/0"]
}

ingress {
		 from_port = 22
		 to_port = 22
		 protocol = "tcp"
		 cidr_blocks = ["0.0.0.0/0"]
}

tags {
		Name = "AppserverSG-Export"
	}
}

#DB Security Group
resource "aws_security_group" "dbserver_group" {

name        = "dbserversg"
description = "Allow Ports 9043"
vpc_id      = "${aws_vpc.vpc_export.id}"

ingress {
		 from_port = 9043
		 to_port = 9043
		 protocol = "tcp"
		 cidr_blocks = ["0.0.0.0/0"]
}

tags {
		Name = "DBserveSG-Export"
	}
}

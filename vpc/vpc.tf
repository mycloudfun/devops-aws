# VPC
resource "aws_vpc" "devops-vpc" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    enable_classiclink = "false"
    tags {
        Name = "devops-vpc"
    }
}
# SUBNETS
resource "aws_subnet" "devops_pub_eu_west-1a" {
    vpc_id = "${aws_vpc.devops-vpc.id}"
    cidr_block = "10.0.0.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "eu-west-1a"

    tags {
        Name = "devops_pub_eu_west-1a"
    }
}

resource "aws_subnet" "devops_pub_eu_west-1b" {
    vpc_id = "${aws_vpc.devops-vpc.id}"
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "eu-west-1b"

    tags {
        Name = "devops_pub_eu_west-1b"
    }
}

resource "aws_subnet" "devops_priv_eu_west-1a" {
    vpc_id = "${aws_vpc.devops-vpc.id}"
    cidr_block = "10.0.128.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "eu-west-1a"

    tags {
        Name = "devops_priv_eu_west-1a"
    }
}

resource "aws_subnet" "devops_priv_eu_west-1b" {
    vpc_id = "${aws_vpc.devops-vpc.id}"
    cidr_block = "10.0.129.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "eu-west-1b"

    tags {
        Name = "devops_priv_eu_west-1b"
    }
}
# Internet GW
resource "aws_internet_gateway" "devops-ig" {
    vpc_id = "${aws_vpc.devops-vpc.id}"

    tags {
        Name = "devops-ig"
    }
}
# NAT Gatewys
resource "aws_eip" "nat1" {
  vpc      = true
}

resource "aws_eip" "nat2" {
  vpc      = true
}

resource "aws_nat_gateway" "devops-ng-az-1" {
  allocation_id = "${aws_eip.nat1.id}"
  subnet_id = "${aws_subnet.devops_pub_eu_west-1a.id}"
  depends_on = ["aws_internet_gateway.devops-ig"]
}

resource "aws_nat_gateway" "devops-ng-az-2" {
  allocation_id = "${aws_eip.nat2.id}"
  subnet_id = "${aws_subnet.devops_pub_eu_west-1b.id}"
  depends_on = ["aws_internet_gateway.devops-ig"]
}
# MAIN-PUBLIC route table
resource "aws_route_table" "main-public" {
    vpc_id = "${aws_vpc.devops-vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.devops-ig.id}"
    }
    tags {
        Name = "main-public"
    }
}

# Route association
resource "aws_route_table_association" "main-public-1-a" {
    subnet_id = "${aws_subnet.devops_pub_eu_west-1a.id}"
    route_table_id = "${aws_route_table.main-public.id}"
}

resource "aws_route_table_association" "main-public-1-b" {
    subnet_id = "${aws_subnet.devops_pub_eu_west-1b.id}"
    route_table_id = "${aws_route_table.main-public.id}"
}

# PRIVATE-AZ-1 route table
resource "aws_route_table" "private-az-1" {
    vpc_id = "${aws_vpc.devops-vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${aws_nat_gateway.devops-ng-az-1.id}"
    }

    tags {
        Name = "private-az-1"
    }
}

# Route association
resource "aws_route_table_association" "main-private-1-a" {
    subnet_id = "${aws_subnet.devops_priv_eu_west-1a.id}"
    route_table_id = "${aws_route_table.private-az-1.id}"
}

# PRIVATE-AZ-2 route table
resource "aws_route_table" "private-az-2" {
    vpc_id = "${aws_vpc.devops-vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${aws_nat_gateway.devops-ng-az-2.id}"
    }

    tags {
        Name = "private-az-2"
    }
}

# Route association
resource "aws_route_table_association" "main-private-1-b" {
    subnet_id = "${aws_subnet.devops_priv_eu_west-1b.id}"
    route_table_id = "${aws_route_table.private-az-2.id}"
}


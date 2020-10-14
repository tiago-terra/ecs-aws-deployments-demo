resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
}
 
resource "aws_subnet" "blue" {
  availability_zone = "${var.region}a"
  cidr_block        = "10.0.10.0/24"
  vpc_id            = aws_vpc.main.id
}
 
resource "aws_subnet" "green" {
  availability_zone = "${var.region}b"
  cidr_block        = "10.0.30.0/24"
  vpc_id            = aws_vpc.main.id 
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id
}
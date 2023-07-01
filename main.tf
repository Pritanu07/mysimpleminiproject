resource "aws_instance" "webserver-1" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  keypair       = "priya-git-keypair"
  associate_public_ip_address ="true"
  subnet_id     = "10.0.0.0/20"
  vpc_security_group_ids = aws_security_group.allow_tls.id

  tags = {
    Name = "HelloWorld"
  }
}

resource "aws_instance" "webserver-2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  keypair = "priya-git-keypair"
  associate_public_ip_address = "true"
  vpc_security_group_ids = aws_security_group.allow_tls.id
  tags = {
    Name = "Welcome to Cloud"
  }
}

#vpc
resource "aws_vpc" "my_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_network_interface" "foo" {
  subnet_id   = aws_subnet.my_subnet.id
  private_ips = ["172.16.10.100"]

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "foo" {
  ami           = "ami-005e54dee72cc1d00" # us-west-2
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_network_interface.foo.id
    device_index         = 0
  }

  credit_specification {
    cpu_credits = "unlimited"
  }
}


# Security group
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.main.cidr_block]
    ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}
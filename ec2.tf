resource "aws_key_pair" "common_ssh" {
  key_name   = "common-ssh"
  public_key = "${var.ec2_public_key}"
}

data "aws_ssm_parameter" "amzn2_latest_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_instance" "cocktail_phpmyadmin" {
  ami = data.aws_ssm_parameter.amzn2_latest_ami.value
  instance_type = "t2.micro"
  key_name   = "common-ssh"
  vpc_security_group_ids = [
    "${aws_security_group.cocktail_sg_ec2.id}"
  ]
  subnet_id = "${aws_subnet.cocktail_public_subnet_1a.id}"
  associate_public_ip_address = "true"
  ebs_block_device {
    device_name    = "/dev/xvda"
    volume_type = "gp2"
    volume_size = 30
  }
  tags  = {
    Name = "${var.r_prefix}-phpmyadmin"
  }
}

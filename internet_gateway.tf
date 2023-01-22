resource "aws_internet_gateway" "cocktail_igw" {
  vpc_id = "${aws_vpc.cocktail_vpc.id}"

  tags = {
    Name = "${var.r_prefix}-igw"
  }
}

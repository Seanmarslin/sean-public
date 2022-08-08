
// elastic ip creation
resource "aws_eip" "aws-public-eip" {
  count = var.aws_nat_gateways
  vpc   = true

  tags = {
   Name = "aws-public-${var.environment}"
 }

}
// Nat-gateway creation
  resource "aws_nat_gateway" "aws-gw" {
    count         = var.aws_nat_gateways
    allocation_id = element(aws_eip.aws-public-eip[*].id, count.index)
    subnet_id     = element(var.aws_subnet_public_ids[*], count.index)
    depends_on    = [var.internet_gw]

    tags = {
      Name = "aws-public-${var.environment}"
    }
}

// main route table
resource "aws_route_table" "aws-private_route-table" {
  count = var.aws_nat_gateways

    vpc_id = var.vpc_id

    tags = {
      Name = "${var.route_table_name}-${var.environment}"
  }
}

resource "aws_route_table_association" "private-rt-association" {
  count          = var.aws_nat_gateways

  subnet_id      = element(var.private_subnet_ids[*], count.index)
  route_table_id = element(aws_route_table.aws-private_route-table[*].id, count.index)

}

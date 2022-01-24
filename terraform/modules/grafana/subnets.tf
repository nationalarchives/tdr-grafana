data "aws_availability_zones" "available" {}

data "aws_nat_gateway" "public" {
  count = var.az_count
  tags = {
    Name = "nat-gateway-${count.index}-mgmt-mgmt"
  }
}

# Create var.az_count private subnets, each in a different AZ
resource "aws_subnet" "private" {
  count             = var.az_count
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, count.index + 6)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = var.vpc_id

  tags = merge(
    var.common_tags,
    tomap({
      "Name" = "tdr-grafana-private-subnet-${count.index}-${var.environment}"
    })
  )
}

# Create var.az_count public subnets, each in a different AZ
resource "aws_subnet" "public" {
  count                   = var.az_count
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, var.az_count + count.index + 2)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = var.vpc_id
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    tomap({
      "Name" = "tdr-grafana-public-subnet-${count.index}-${var.environment}"
    })
  )
}

# Create a new route table for the private subnets, make it route non-local traffic through the NAT gateway to the internet
resource "aws_route_table" "private" {
  count  = var.az_count
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = data.aws_nat_gateway.public[count.index].id
  }

  tags = merge(
    var.common_tags,
    tomap({
      "Name" = "route-table-${count.index}-tdr-grafana-${var.environment}"
    })
  )
}

# Explicitly associate the newly created route tables to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "private" {
  count          = var.az_count
  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = aws_route_table.private.*.id[count.index]
}

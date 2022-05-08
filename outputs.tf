output "vpc_cidr" {
  value = module.vpc_network.vpc_cidr
}

output "public_subnet_1_cidr" {
  value = module.vpc_network.public_subnet_1_cidr
}

output "private_subnet_1_cidr" {
  value = module.vpc_network.private_subnet_1_cidr
}
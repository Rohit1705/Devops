# variables.tf


variable "access_key" {
     default = "<PUT IN YOUR AWS ACCESS KEY>"
}
variable "secret_key" {
     default = "<PUT IN YOUR AWS SECRET KEY>"
}
variable "region" {
     default = "us-east-1"
}
variable "availabilityZone1" {
     default = "us-east-1a"
}

variable "availabilityZone2" {
     default = "us-east-1b"
}

variable "instanceTenancy" {
    default = "default"
}

variable "vpcCIDRblock" {
    default = "10.0.0.0/16"
}
variable "subnetCIDRblock1" {
    default = "10.0.1.0/24"
}

variable "subnetCIDRblock2" {
    default = "10.0.2.0/24"
}
variable "destinationCIDRblock" {
    default = "0.0.0.0/0"
}
variable "ingressCIDRblock" {
    type = list
    default = [ "0.0.0.0/0" ]
}
variable "egressCIDRblock" {
    type = list
    default = [ "0.0.0.0/0" ]
}
variable "mapPublicIP" {
    default = true
}

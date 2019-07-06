variable "openvpn_provider" {
  description = "The OpenVPN provider to use. See https://haugene.github.io/docker-transmission-openvpn/arguments/#required_environment_options"
}
variable "openvpn_config" {
  description = "The VPN endpoint to use. See https://haugene.github.io/docker-transmission-openvpn/arguments/#network_configuration_options"
}
variable "openvpn_username" {
  description = "Your VPN provider username"
}
variable "openvpn_password" {
  description = "Your VPN provider password"
}
variable "aws_region" {
  description = "Region to launch the instance in e.g. ap-southeast-2"
}
variable "aws_key_name" {
  description = "The name of an existing keypair in your AWS account to assign to the instance"
}
variable "aws_vpc_id" {
  description = "The VPC to launch the instance into"
}
variable "aws_subnet_id" {
  description = "The public subnet to launch the instance into"
}
variable "aws_s3_bucket" {
  description = "The name of the S3 bucket in your AWS account to upload completed files to"
}
variable "aws_instance_type" {
  default     = "t2.micro"
  description = "The EC2 instance type to use"
}
variable "path_pattern" {
  default     = ""
  description = "A regular expression used to filter paths. For example \"mp4$\" would only upload files ending with \"mp4\"."
}

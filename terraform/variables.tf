variable "ssh_public_key_path" {
  description = "The file path to the public SSH key to be added to the EC2 instance."
  type        = string
}

variable "minecraft_jar_url" {
  description = "The download URL for the Minecraft server."
  type        = string
}

variable "aws_region" {
  type        = string
  default     = "us-west-2" 
}

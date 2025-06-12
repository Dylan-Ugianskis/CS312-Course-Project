output "instance_public_ip" {
  description = "The public IP address of the Minecraft server instance."
  value       = aws_instance.minecraft_server.public_ip
}

output "connect_command" {
  description = "Use this Nmap command to check if the server is running."
  value       = "nmap -sV -Pn -p T:25565 ${aws_instance.minecraft_server.public_ip}"
}

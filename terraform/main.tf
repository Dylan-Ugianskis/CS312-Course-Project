# --- Networking ---

resource "aws_vpc" "minecraft_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Minecraft-VPC"
  }
}

resource "aws_subnet" "minecraft_subnet" {
  vpc_id                  = aws_vpc.minecraft_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true # public IP
  availability_zone       = "${var.aws_region}a" 
  tags = {
    Name = "Minecraft-Subnet"
  }
}

resource "aws_internet_gateway" "minecraft_igw" {
  vpc_id = aws_vpc.minecraft_vpc.id
  tags = {
    Name = "Minecraft-IGW"
  }
}

resource "aws_route_table" "minecraft_rt" {
  vpc_id = aws_vpc.minecraft_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.minecraft_igw.id
  }

  tags = {
    Name = "MinecraftRTable"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.minecraft_subnet.id
  route_table_id = aws_route_table.minecraft_rt.id
}

# --- Security ---

resource "aws_security_group" "minecraft_sg" {
  name        = "minecraft-server-sg"
  vpc_id      = aws_vpc.minecraft_vpc.id

  # Allow SSH for Ansible to configure the server 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Minecraft traffic
  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Minecraft-SG"
  }
}

resource "aws_key_pair" "minecraft_key" {
  key_name   = "minecraft-automation-key"
  public_key = file(var.ssh_public_key_path)
}

# --- Compute ---

resource "aws_instance" "minecraft_server" {
  # Using Amazon Linux 2023 for us-west-2. 
  ami           = "ami-05f9478b4deb8d173"
  instance_type = "t2.micro" 

  subnet_id              = aws_subnet.minecraft_subnet.id
  vpc_security_group_ids = [aws_security_group.minecraft_sg.id]
  key_name               = aws_key_pair.minecraft_key.key_name

  tags = {
    Name = "Minecraft-Server-Instance"
  }
}

# --- Automation Helper: Create Ansible Inventory ---

resource "local_file" "ansible_inventory" {
  content  = <<EOT
[minecraft]
${aws_instance.minecraft_server.public_ip}

[minecraft:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=~/.ssh/minecraft_rsa
EOT
  filename = "../ansible/inventory.ini"
}

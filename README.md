# CS 312 Project #2 - Automated AWS Minecraft Server Deployment using Terraform and Ansible
## This project fully automates the provisioning and configuration of a Minecraft Java Edition server on Amazon Web Services for CS312 System Administration. It uses a combination of Terraform for Infrastructure    as Code and Ansible for configuration management to ensure a repeatable, hands-off deployment.

Architecture Diagram
The deployment pipeline follows these major steps from your local machine:

    A[User runs `terraform apply`] --> B{Terraform Provisions AWS Resources};
    B --> C[VPC, Subnet, Security Group];
    B --> D[EC2 Instance & Key Pair];
    B --> E[Outputs Public IP];
    subgraph "Local Machine"
        F[User runs `ansible-playbook`]
    end
    F --> G{Ansible Configures EC2 Instance};
    G --> H[Install Java 21 & Screen];
    G --> I[Download Minecraft Server JAR];
    G --> J[Enable minecraft.service];
    J --> K[Minecraft Server is Running];

### Project Structure
Your final repository should have the following structure:

```
├── ansible/
│   ├── ansible.cfg
│   ├── inventory.ini 
│   ├── playbook.yml
│   └── templates/
│       └── minecraft.service.j2
├── terraform/
│   ├── main.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── terraform.tfvars 
│   └── variables.tf
└── README.md
```

## Requirements
The following tools must be installed and credentials have to be configured on your local machine.

### Tools
Git: For cloning this repository.

Terraform: For provisioning AWS infrastructure. Install Terraform

Ansible: For configuring the EC2 instance. Install Ansible

AWS CLI: For programmatic access to your AWS account. Install AWS CLI

nmap: For verifying the server port is open.

### Credentials & Configuration
AWS Credentials:
Your local environment must be configured with AWS credentials. The simplest method is to set the following environment variables in your terminal:

`export AWS_ACCESS_KEY_ID="YOUR_AWS_ACCESS_KEY"`

`export AWS_SECRET_ACCESS_KEY="YOUR_AWS_SECRET_KEY"`

`export AWS_SESSION_TOKEN="YOUR_SESSION_TOKEN" `

`export AWS_DEFAULT_REGION="us-west-2" `

SSH Key Pair and Agent: To load an EC2 intanse without SSH requires an SSH key to be loaded into your ssh-agent.

Create an SSH Key:

`ssh-keygen -t rsa -b 4096 -f ~/.ssh/minecraft_rsa`

`This creates a private key (~/.ssh/minecraft_rsa) and a public key (~/.ssh/minecraft_rsa.pub). `

Add Your Key to the Agent: This step securely loads your key so Ansible can use it.

`ssh-add ~/.ssh/minecraft_rsa`

# Local Setup and Execution
 ## 1. Clone the Repository
  Clone this project from GitHub to your local machine.

  `git clone <https://github.com/Dylan-Ugianskis/CS312-Course-Project.git>`
  
  `cd <Auto-Minecraft>`

## 2. Configure Terraform Variables
  Navigate to the terraform directory and create a file named terraform.tfvars to specify your unique settings.
  
  `cd terraform`
  
  `vim terraform.tfvars`
  
  Paste the following content into the file, updating the values as needed.
  
  ` terraform/terraform.tfvars:`
 ``` 
  # Path to the PUBLIC key file you created above.
  ssh_public_key_path = "~/.ssh/minecraft_rsa.pub"
  
  # The Minecraft server JAR download URL.
  # Get the latest from: https://www.minecraft.net/en-us/download/server
  minecraft_jar_url = "https://piston-data.mojang.com/v1/objects/125e5adf40c659fd3bce3e864c68644221527231/server.jar"
```
## 3. Deploy the Server
  Execute the following commands in sequence.
  
  Initialize Terraform:
  
  `terraform init`
  
  Provision the Infrastructure:
  
  This command will build all the AWS resources
  
  `terraform apply`
  
  When prompted type “yes” to continue 
  
  Configure the Server:
  
  Navigate to the ansible directory and run the playbook.
  ```
  cd ../ansible
  ansible-playbook playbook.yml
  ```
  This will install Java 21, download Minecraft, and start the service.

## 4. Verify the Deployment
  Get the Server IP:
  The server's public IP address is in ansible/inventory.ini and was also displayed in the Terraform output.
  
  Verify with Nmap:
  Use nmap to confirm the server is running and the port is accessible.
  
  `nmap -sV -Pn -p T:25565 <your_instance_public_ip>`
  
  A successful scan will show the port state as open.
  
  Connect with the Minecraft Client:
  
  Launch Minecraft: Java Edition.
  
  Go to Multiplayer -> Direct Connect.
  
  Enter the <your_instance_public_ip> in the Server Address field and connect!

## 5. Cleanup / Destroying Resources
  To avoid ongoing AWS charges, run this command to destroy all the resources you created.
  
  ### Navigate back to the terraform directory and destroy the resources
  ```
  cd ../terraform/
  terraform destroy
  ```

## Resources and Sources
The following resources were instrumental in developing the Terraform and Ansible scripts.

## Terraform
The Terraform code for provisioning the AWS infrastructure was based on the official HashiCorp AWS Provider documentation.

[Infrastructure](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-build)

## VPC and Networking:

[aws_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)

[aws_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)

[aws_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway)

[aws_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)


## Compute and Security:

[aws_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)

[aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)

[aws_key_pair](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair)


## Automation Helper:

[local_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) (Used for generating the Ansible inventory)

## Ansible
The Ansible playbook for server configuration utilized several core modules.

[ansible.builtin.dnf](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/dnf_module.html) - For package management on Amazon Linux 2023.

[ansible.builtin.user](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/user_module.html) - For creating the dedicated minecraft user.

[ansible.builtin.template](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html) - For deploying the systemd service file.

[ansible.builtin.systemd](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/systemd_module.html) - For managing the Minecraft service.

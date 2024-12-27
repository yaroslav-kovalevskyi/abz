# WordPress Server Infrastructure

## Description

This repository provisions a WordPress Server backed by a dedicated MySQL database and a Redis instance. By default, all resources are AWS Free Tier eligible.

### Key Features

- **Modules**:
  - **Networking**: Connects seamlessly using module outputs.
  - **WordPress**: Includes an EC2 instance, MySQL database, and Redis in-memory cache instance.
- **Security**:

  - Public access allowed on HTTP and HTTPS ports (80/443).
  - Internal traffic within the VPC is secured via Private IPs for communication between:
    - WordPress Server and MySQL database.
    - WordPress Server and Redis instance.
  - SSH Access to EC2 instance allowed only from well known IPs specified in the `wellknown_ip` environment variable in the `main.tf` file

    - SSH private key is created during deployment and passing to instance.
      Copy of the key stores in `../ssh/`

- **Post-Installation Configuration**:
  - Automated via a Bash script located at `../wp/wordpress_bootstrap.sh`.
  - Executing by the `remote-exec` Terraform provisioner.
- **Required Environment Variables**:
  - Securely passing with a `user_data` script executed during instance initialization.

## Customization

To adjust the infrastructure, modify the variable values in the `main.tf` file to suit your requirements.

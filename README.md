# Infrastructure as Code (IaC) Repository

## Overview

This repository contains scripts and configurations for managing infrastructure and deployments using Infrastructure as Code (IaC) principles. We use Terraform for provisioning and managing cloud resources and Ansible for configuration management and deployment automation.

## Contents

- `terraform/`: Terraform configurations for cloud infrastructure.
- `ansible/`: Ansible playbooks for configuration management.
- `scripts/`: PowerShell scripts for managing Windows updates and reboots.
- `Servers.txt`: List of servers for update management.
- `UpdateLog.txt`: Log file for Windows update records.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed on your local machine.
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) installed on your local machine.
- [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell) installed on your local machine.
- Access to your cloud provider account (e.g., AWS, Azure, GCP).
- Properly configured SSH keys for accessing remote servers.

## Terraform Setup

1. **Initialize Terraform**:

    ```sh
    cd terraform
    terraform init
    ```

2. **Plan Infrastructure Changes**:

    ```sh
    terraform plan
    ```

3. **Apply Infrastructure Changes**:

    ```sh
    terraform apply
    ```

## Ansible Setup

1. **Run Ansible Playbooks**:

    ```sh
    ansible-playbook -i ansible/inventory ansible/playbook.yml
    ```

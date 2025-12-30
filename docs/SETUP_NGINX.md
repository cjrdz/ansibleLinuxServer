# Nginx Setup in Ubuntu Server playbook

## Overview
This Ansible playbook sets up Nginx on a server and configures it to serve static content with a index.html file on a Oracle Cloud Infrastructure (OCI) instance.

## What This Playbook Does
- Installs Nginx
- Configures Nginx to serve static content
- Creates an index.html file

## Prerequisites
❗**Important**:
You must have a valid OCI account and create a linux ubuntu server instance on free tier, also need to configure your VCN with a public IP address and security list rules to allow HTTP traffic. SSH key-based authentication must be configured **before** running this playbook

## Requirements
- Python 3.6 or later installed on the control machine
- Ansible 2.9 or later installed on the control machine
- SSH access to the target ubuntu server instance with proper credentials (private ssh key)

## Configuration
- You need to create a OCI instance with your prefer name and select Ubuntu Server as the image.
- You need to configure your VCN with a public IP address and security list rules to allow HTTP traffic. 

**Ingress Rules Table:**
| Stateless |   Source    | IP Protocol | Source PR | Destination PR | Description      |
|-----------|-------------|-------------|-----------|----------------|------------------|
| No        | 0.0.0.0/0   | TCP         | All       | 22             | SSH Remote Login |
| No        | 0.0.0.0/0   | TCP         | All       | 80             | HTTP Web Server  |
| No        | 0.0.0.0/0   | TCP         | All       | 443            | HTTPS Web Server |

## Usage
First, ensure that you have the necessary prerequisites in place. Then, run the playbook using the following command:

## Expected results

## When to use this playbook

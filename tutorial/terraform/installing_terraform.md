# Installing Terraform on Ubuntu

This tutorial will guide you through the installation of Terraform. It install necessary dependencies, adds GPG keys to verify the authenticity of the packages and finally installs Terraform itself.

## Steps
Update apt and install the gnupg software
```
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
```

Download and install the HashiCorp GPG key for package verification
```
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
```
Verify the GPG key:
```
gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint
```

Add the Hashicorp repository to the system:
```
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
```
Update apt to download the package information:
```
sudo apt update
```
Install Terraform from the new repository:
```
sudo apt-get install terraform
```
Verify the installation by running: 
```
terraform -help
```
You should see all Terraform commands that are available with the current installation.
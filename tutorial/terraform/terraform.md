**Terraform**

Finally, Terraform needs to be installed. Run the following commands:
1. Update apt and install the gnupg software
  - sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
2. Install the GPG key
  - wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
3. Verify the GPG key:
  - gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint

4. Add the Hashicorp repository to the system:
  - echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

5. Update apt to download the package information:
  - sudo apt update

6. Install Terraform from the new repository:
  - sudo apt-get install terraform

7. Verify the installation by running: 
  - terraform -help
  
You should see all terraform commands that are available with the current installation.
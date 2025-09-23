# Install Docker
This tutorial will guide you through each step of installing Docker in a Ubuntu environment. Docker is used to containerize Snort and the HTTP server later in the tutorial. 

## Steps
Set up Docker's apt repository: 
```
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

Add the repository to apt sources:
```
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

Install the latest version: 
  
```
sudo apt-get install docker-ce docker-ce-cli containerd.io 
docker-buildx-plugin docker-compose-plugin
```

Hit 'Y' and enter to begin installation. After a while you will be prompted with `*** config.toml (Y/I/N/O/D/Z) [default=N] ?`. Hit 'N' and enter to accept default configuration.

Check docker service:
```
docker --version
```
If you see `Docker version 28.4.0, build d8eb465` the installation is OK!
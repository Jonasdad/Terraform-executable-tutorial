# Using the installed tools

Now that all the required tools are installed.

1. Navigate to the home directory
```
cd filesystem/home/Ubuntu
```
2. Create a directory called terraform

```
mkdir Terraform
```
3. Move into the newly created directory
```
cd Terraform
```
4. Make a 'main.tf' file
```
touch main.tf
```
5. Open 'main.tf' in a text editor
```
nano main.tf
```
## Working with Terraform

Terraform requires a main.tf file which specifies which resources are to be run, from where and what their dependencies are. 

First, Terraform needs to know which providers of the services you plan to use are. In this tutorial, Docker is used which Kreuzwerker supplies to Terraform. To specify this, paste, the contents below into the main.tf file. If the provider Kreuzwerker for some reason doesn't 


```
terraform{
	required_providers {
		docker = {
			source = "kreuzwerker/docker"
			version = "~> 3.0.1"	
		}
	}
}
```

Secondly, we must specifiy which docker containers we want terraform to intialize and how they're supposed to be configured. To do this we specifiy two kinds of resources. 
1. docker_image
2. docker_container

The docker_image specifies the name of the image, what type of resource it is (an image in this case) and which version of the image is to be loaded onto the current system using a docker tag which in this case is __:latest__

```
resource "docker_image" "http" {
	name = "pilsnerfrajz/http-server:latest"
}
resource "docker_image" "snort"{
	name = "pilsnerfrajz/snort-server:latest"
}
```

Now, the images instances (containers) operating mode must be specified through the __docker_container__ resource. This resource type allows many configuration types as cpu usage, gpu_usage, timeout requirements, network configurations and many more. For the purposes of this tutorial the parameters, name, entrypoint, image id, must_run and network-dependencies are sufficient. Please see copy and paste the configuration below into your main.tf file.
```
resource "docker_container" "http" {
	name = "http-server"
	entrypoint = [ "/usr/local/bin/run.sh" ]
	image = docker_image.http.image_id
	must_run = true
}
```
resource "docker_container" "snort" {
	name = "snort"
	entrypoint = [ "/etc/snort/run-snort.sh" ]
	image = docker_image.snort.image_id
	must_run = true
	
}

Finally, in order for these containers to communicate over a docker network, we must create one. Open a new terminal tab and run the command:
```
docker network create container_network
```

The output of the command is the network ID for the newly created Docker network. Copy the network ID run the terraform command:

```
terraform import docker_network.container_network <paste ID here>
```

Now we must specifiy in terraforms configuration file main.tf that this is a resource we want to use for our containers. Go back to the previous terminal tab and define the new docker new work resource like below in the main.tf file. 
```
resource "docker_network" "container_network" {
	name = "container_network"
}
```

This simply tells Terraform that there exists a docker network called container_network. To use this network we must specify that the containers will use this network and that they are dependent on it. Meaning, that if the network doesn't exist, the containers will not launch.

Inside your main.tf folder, locate the two __docker_container__ resources __http__ and __snort__. Inside the each resource, specify an advanced network parameter, nested with the network name. Outside the __networks_advanced__ parameter, but inside the __docker_container__ resource, specify that the container is dependent on this network. See below for the correct configuration:

```
resource "docker_container" "http" {
	name = "http-server"
	entrypoint = [ "/usr/local/bin/run.sh" ]
	image = docker_image.http.image_id

	networks_advanced {
	  name = docker_network.container_network.name
	}

	must_run = true

	depends_on = [ docker_network.container_network ]
}

resource "docker_container" "snort" {
	name = "snort"
	entrypoint = [ "/etc/snort/run-snort.sh" ]
	image = docker_image.snort.image_id
	networks_advanced {
	  name = docker_network.container_network.name
	}
	must_run = true
	
	depends_on = [ docker_network.container_network ]
}

```

Now the main.tf is configured for use of the two pulled docker containers and is ready for use! Your final main.tf should look like this:

```
terraform{
	required_providers {
		docker = {
			source = "kreuzwerker/docker"
			version = "~> 3.0.1"	
		}
	}
}

resource "docker_network" "container_network" {
	name = "container_network"
}

resource "docker_image" "http" {
	name = "pilsnerfrajz/http-server:latest"
}

resource "docker_container" "http" {
	name = "http-server"
	entrypoint = [ "/usr/local/bin/run.sh" ]
	image = docker_image.http.image_id

	networks_advanced {
	  name = docker_network.container_network.name
	}

	must_run = true

	depends_on = [ docker_network.container_network ]
}

resource "docker_image" "snort"{
	name = "pilsnerfrajz/snort-server:latest"
}
resource "docker_container" "snort" {
	name = "snort"
	entrypoint = [ "/etc/snort/run-snort.sh" ]
	image = docker_image.snort.image_id
	networks_advanced {
	  name = docker_network.container_network.name
	}
	must_run = true
	
	depends_on = [ docker_network.container_network ]
}
```
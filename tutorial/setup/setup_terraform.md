# Putting it all together - Terraform

This tutorial will go through the steps of configuring Terraform to run the two Docker containers. It will explain the steps to specify Terraform resources, providers and dependencies. It will proceed with setting up a Docker network for the containers to communicate over.

## Setting up the Terraform directory

Create a directory called Terraform and navigate into it:
```bash
cd
mkdir terraform
cd terraform
```

Open `main.tf` in a text editor
```bash
nano main.tf
```
## Working with Terraform

Terraform requires a `main.tf` file which specifies which resources are to be run, from where and what their dependencies are. 

First, Terraform needs to know which providers of the services you plan to use are. In this tutorial, Docker is used which Kreuzwerker supplies to Terraform. To specify this, paste, the contents below into the `main.tf` file. If the provider Kreuzwerker for some reason doesn't **MISSING TEXT HERE**


```bash
terraform{
	required_providers {
		docker = {
			source = "kreuzwerker/docker"
			version = "~> 3.0.1"	
		}
	}
}
```

Secondly, we must specifiy which Docker containers we want Terraform to intialize and how they're supposed to be configured. To do this we specifiy two kinds of resources: 
1. docker_image
2. docker_container

The docker_image specifies the name of the image, what type of resource it is (an image in this case) and which version of the image is to be loaded onto the current system using a Docker tag which in this case is __:latest__

```bash
resource "docker_image" "http" {
	name = "pilsnerfrajz/http-server:latest"
}
resource "docker_image" "snort"{
	name = "pilsnerfrajz/snort-server:latest"
}
```
> Note: pilsnerfrajz is a co-author to this tutorial has prepared both Docker images on Docker Hub as they are not deemed as an important learning outcome of this tutorial.


Now, the images' instances (containers) operating mode must be specified through the __docker_container__ resource. This resource type allows many configuration types as `cpu_usage`, `gpu_usage`, `timeout requirements`, `network configurations` and many more. For the purposes of this tutorial the parameters, `name`, `entrypoint`, `image`, `must_run` and network-dependencies are sufficient. Please copy and paste the configuration below into your `main.tf` file.
```bash
resource "docker_container" "http" {
	name = "http-server"
	entrypoint = [ "/usr/local/bin/run.sh" ]
	image = docker_image.http.image_id
	must_run = true
}

resource "docker_container" "snort" {
	name = "snort"
	entrypoint = [ "/etc/snort/run-snort.sh" ]
	image = docker_image.snort.image_id
	must_run = true
	
}
```

Finally, in order for these containers to communicate over a docker network, we must create one. Open a new terminal tab by pressing `ctrl + shift + t` and run the command:
```bash
docker network create container_network
```

The output of the command is the network ID for the newly created Docker network. Copy the network ID and run the following Terraform command in the same terminal window:
```bash
terraform import docker_network.container_network <paste ID here>
```

Now we must specifiy that this is a resource we want to use for our containers. Go back to the previous terminal tab and define the new Docker network resource like below in the `main.tf` file. 
```bash
resource "docker_network" "container_network" {
	name = "container_network"
}
```

This simply tells Terraform that there exists a Docker network called `container_network`. To use this network we must specify that the containers will use this network and that they are dependent on it. However, if the network doesn't exist, Terraform will create a Docker network for us! This step is really just to explain what is happening and why.

Inside your `main.tf` file, locate the two __docker_container__ resources __http__ and __snort__. Inside the each resource, specify an advanced network parameter, nested with the network name. Outside the __networks_advanced__ parameter, but inside the __docker_container__ resource, specify that the container is dependent on this network. See below for the correct configuration:

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
Please save the main.tf file by press `ctrl + s ` to save the contents, and then `ctrl + x` to exit.
## What we have done

In this part of the tutorial we explained some key functionalities of Terraform and how to configure the config files to successfully run the intended docker containers.

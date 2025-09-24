# Putting it all together - Terraform

This tutorial will go through the steps of configuring Terraform to run the two Docker containers. It will explain the steps to specify Terraform resources, providers and dependencies. It will proceed with setting up a Docker network for the containers to communicate over.

## Setting up the Terraform directory

Create a directory called Terraform and navigate into it:
```
cd
mkdir terraform
cd terraform
```

Create and open `main.tf` in a text editor
```
touch main.tf
nano main.tf
```
## Working with Terraform

Terraform requires a `main.tf` file which specifies which resources are to be run, from where and what their dependencies are. 

First, Terraform needs to know which providers of the services you plan to use are. In this tutorial, Docker is used which Kreuzwerker supplies to Terraform. To specify this, paste, the contents below into the `main.tf` file. If the provider Kreuzwerker for some reason doesn't **MISSING TEXT HERE**


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

Secondly, we must specifiy which Docker containers we want Terraform to intialize and how they're supposed to be configured. To do this we specifiy two kinds of resources: 
1. docker_image
2. docker_container

The docker_image specifies the name of the image, what type of resource it is (an image in this case) and which version of the image is to be loaded onto the current system using a Docker tag which in this case is __:latest__

```
resource "docker_image" "http" {
	name = "pilsnerfrajz/http-server:latest"
}
resource "docker_image" "snort"{
	name = "pilsnerfrajz/snort-server:latest"
}
```
> Note: pilsnerfrajz is a co-author to this tutorial has prepared both Docker images on Docker Hub as they are not deemed as an important learning outcome of this tutorial.

In case you created the images yourself, you should use the names you specified when building the images. For example, if you built the Snort image yourself, you should use `snort:latest` and `http-server:latest` as the names of the images, instead of `pilsnerfrajz/http-server:latest` and `pilsnerfrajz/snort-server:latest`.


Now, the operating mode of the containers must be specified through the `docker_container` resource. This resource type allows many configuration types as `cpu_usage`, `gpu_usage`, `timeout requirements`, `network configurations` and many more. For the purposes of this tutorial the parameters, `name`, `entrypoint`, `image`, `must_run` and network-dependencies are sufficient. Please copy and paste the configuration below into your `main.tf` file.
```
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

The above configuration will run the images with the scripts specified in the `entrypoint` parameter. See the previous tutorials for more information about these scripts. 

Define the new Docker network resource like below in the `main.tf` file. When running this configuration file a docker command to create a network is executed and will be used by this terraform configuration for container communication.

```
resource "docker_network" "container_network" {
	name = "container_network"
}
```

Inside your `main.tf` file, locate the two `docker_container` resources `http` and `snort`. Inside of each resource, specify an advanced network parameter, nested with the network name. Outside the `networks_advanced` parameter, but inside the `docker_container` resource, specify that the container is dependent on this network. See below for the correct configuration:

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

Now the `main.tf` is configured for use of the two pulled Docker containers and is ready for use! Your final `main.tf` should look like this:

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
Please save the `main.tf` file by pressing `ctrl + X` followed by `y` and `enter`.

## What we have done
- We have created a configuration file for Terraform
- We have defined the necessary Docker resources such as images, containers, and networks
- We explained some key functionalities of Terraform to understand how it works

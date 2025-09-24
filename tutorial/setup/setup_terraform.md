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

First, Terraform needs to know which providers of the services you plan to use are. In this tutorial, Docker is used which Kreuzwerker supplies to Terraform. To specify this, paste, the contents below into the `main.tf` file. If the provider Kreuzwerker for some reason isn't available, the terraform configuration will not work and is outside of our control. Please come back later and try again.


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

### Using Your Own Docker Containers
To use the docker containers you optionally could create in the previous steps of the tutorial the configuration file is different than if you decided to skip. **If you did not create your own docker files, please go to the next section!**


We must specify to Terraform what local images we have available and their ID. To do this, save you main.tf file. 

1. Exit main.tf
2. Run `docker images`
3. Save the IDs somewhere
4. In `main.tf`, define your docker containers, where the image references the local image ID like below:

```
resource "docker_container" "snort" {
	name = "snort"
	entrypoint = [ "/etc/snort/run-snort.sh" ]
	image = <image_ID_for_snort_container_here>
	must_run = true
}

resource "docker_container" "http" {
	name = "http-server"
	entrypoint = [ "/usr/local/bin/run.sh" ]
	image = <image_ID_for_http_container_here>
	must_run = true
}
```
Please skip the next part, and go straight to the `Docker Network Setup` section

### Pulling Containers from Docker Hub
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
resource "docker_container" "snort" {
	name = "snort"
	entrypoint = [ "/etc/snort/run-snort.sh" ]
	image = docker_image.snort.image_id
	must_run = true
}

resource "docker_container" "http" {
	name = "http-server"
	entrypoint = [ "/usr/local/bin/run.sh" ]
	image = docker_image.http.image_id
	must_run = true
}
```

The above configuration will run the images with the scripts specified in the `entrypoint` parameter. See the previous tutorials for more information about these scripts. 
### Docker Network Setup
Define the new Docker network resource like below in the `main.tf` file. When running this configuration file a docker command to create a network is executed and will be used by this terraform configuration for container communication.

```
resource "docker_network" "container_network" {
	name = "container_network"
}
```

Inside your `main.tf` file, locate the two `docker_container` resources `http` and `snort`. Inside of each resource, specify an advanced network parameter, nested with the network name. Outside the `networks_advanced` parameter, but inside the `docker_container` resource, specify that the container is dependent on this network. See below for the correct configuration:

```
resource "docker_container" "snort" {
	name = "snort"
	entrypoint = [ "/etc/snort/run-snort.sh" ]
	image = docker_image.snort.image_id # | or your own image id
	networks_advanced {
	  name = docker_network.container_network.name
	}
	must_run = true
	
	depends_on = [ docker_network.container_network ]
}

resource "docker_container" "http" {
	name = "http-server"
	entrypoint = [ "/usr/local/bin/run.sh" ]
	image = docker_image.http.image_id # | or your own image id

	networks_advanced {
	  name = docker_network.container_network.name
	}

	must_run = true

	depends_on = [ docker_network.container_network ]
}

```
> NOTE: It is crucial that the order of the `docker_container` definition is kept in the main.tf file just like above e.g. snort must be defined first and http-server second.


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
#Skip resource docker_network if you decide to use local images
resource "docker_network" "container_network" {
	name = "container_network"
}
#Skip resource docker_network if you decide to use local images
resource "docker_image" "http" {
	name = "pilsnerfrajz/http-server:latest"
}

resource "docker_container" "http" {
	name = "http-server"
	entrypoint = [ "/usr/local/bin/run.sh" ]
	image = docker_image.http.image_id # | or your own image id

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
	image = docker_image.snort.image_id # | or your own image id
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

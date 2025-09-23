**Using the installed tools**

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
**Working with Terraform**

Terraform requires a main.tf file which specifies which resources are to be run, from where and what their dependencies are. 

First, Terraform needs to know which providers of the services you plan to use are. In this tutorial, Docker is used which Kreuzwerker supplies to Terraform. To specify this, paste, the contents below into the main.tf file.


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

Secondly

```
terraform{
	required_providers {
		docker = {
			source = "kreuzwerker/docker"
			version = "~> 3.0.1"	
		}
	}
}

resource "docker_network" "test" {
	name = "test"
}

resource "docker_image" "http" {
	name = "pilsnerfrajz/http-server:latest"
}

resource "docker_container" "http" {
	name = "http-server"
	entrypoint = [ "/usr/local/bin/run.sh" ]
	image = docker_image.http.image_id

	networks_advanced {
	  name = docker_network.test.name
	}

	must_run = true

	depends_on = [ docker_network.test ]
}

resource "docker_image" "snort"{
	name = "pilsnerfrajz/snort-server:latest"
}
resource "docker_container" "snort" {
	name = "snort"
	entrypoint = [ "/etc/snort/run-snort.sh" ]
	image = docker_image.snort.image_id
	networks_advanced {
	  name = docker_network.test.name
	}
	must_run = true
	
	depends_on = [ docker_network.test ]
}



```
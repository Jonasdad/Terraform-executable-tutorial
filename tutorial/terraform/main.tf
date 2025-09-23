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



# This file contains the code for installing the unified cloudwatch agent
# on the ec2 instance passed as parameter

# Specify provider details
provider "aws" {
   region                  = var.region
 # shared_credentials_file = "~/.aws/credentials"
   #profile                 = "${var.stage}"
   #access_key = var.access_key
   #secret_key = var.secret_key
}

# Load the cloudwatch agent config file
resource "local_file" "write_conf_file" {
    content     = var.logs_config
    filename = "${path.module}/conf/logs_config.json"
}

# ssh into ec2 instance and install the cw agent
resource "null_resource" "install_agent" {
  connection {
    type     = "ssh"
    private_key = file(var.pem_key)
    user     = var.user
    host = var.ip_address
  }

  provisioner "file" {
    source      = "${path.module}/conf/logs_config.json"
    destination = "/tmp/logs_config.json"
  }


  provisioner "file" {
    source      = "${path.module}/install-unified-cw-agent.sh"
    destination = "/tmp/install-unified-cw-agent.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/install-unified-cw-agent.sh",
      "sudo /tmp/install-unified-cw-agent.sh",
    ]
  }

}

# cleanup temp files after instllation
resource "null_resource" "cleanup" {
   provisioner "local-exec" {
    command  = "mv ${path.module}/conf/logs_config.json ${path.module}/conf/logs_config.json.processed"
   }
   depends_on = [null_resource.install_agent]
}

#!/bin/bash
@author Michael Dara
#INSTALL Unified cloud watch agent on the on a EC2 instance

#Copy the cloudwatch_agent.json config file first to /tmp/ folder or directly move to /etc/ folder during bootup
#sudo cp /tmp/cloudwatch_agent.json /etc/cloudwatch_agent.json

# Check the distribution

    . /etc/os-release

      case $NAME in
        "Amazon Linux") echo "Installing the cloudwatch agent for Amazon Linux."
          sudo curl -O https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
          sudo rpm -i ./amazon-cloudwatch-agent.rpm
          ;;
        Centos) echo "Installing the cloudwatch agent for Centos Linux."
          sudo curl -O https://s3.amazonaws.com/amazoncloudwatch-agent/centos/amd64/latest/amazon-cloudwatch-agent.rpm
          sudo rpm -i ./amazon-cloudwatch-agent.rpm
          ;;
        Debian) echo "Installing the cloudwatch agent for Debian Linux."
          sudo curl -O https://s3.amazonaws.com/amazoncloudwatch-agent/debian/amd64/latest/amazon-cloudwatch-agent.deb
          sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
          ;;
        Redhat) echo "Installing the cloudwatch agent for Redhat Linux."
          sudo curl -O https://s3.amazonaws.com/amazoncloudwatch-agent/redhat/amd64/latest/amazon-cloudwatch-agent.rpm
          sudo rpm -i ./amazon-cloudwatch-agent.rpm
          ;;
        Suse) echo "Installing the cloudwatch agent for Suse Linux."
          sudo curl -O https://s3.amazonaws.com/amazoncloudwatch-agent/suse/amd64/latest/amazon-cloudwatch-agent.rpm
          sudo rpm -i ./amazon-cloudwatch-agent.rpm
          ;;
        Ubuntu) echo "Installing the cloudwatch agent for Ubuntu Linux."
          sudo curl -O https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
          sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
          ;;
        *)
         echo "Operating system not supported. Please refer to the official documents for more info https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/install-CloudWatch-Agent-on-first-instance.html"
         exit
      esac

      sleep 5

sudo cat <<EOF > /etc/init.d/cw_startup.sh
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/tmp/amazon-cloudwatch-agent.json -s
EOF

sudo chmod ugo+rwx /etc/init.d/cw_startup.sh

#start the unified cloudwatch agent with the config file (Add to the bootup)
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/tmp/amazon-cloudwatch-agent.json -s

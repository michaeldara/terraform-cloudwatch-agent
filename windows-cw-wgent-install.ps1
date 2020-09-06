##########################################################################################################
#
# WINDOWS POWERSHELL SCRIPT FOR INSTALLING UNIVERSAL CLOUDWATCH AGENT
# @Author: Michael Dara
# Version : 1.0
#
##########################################################################################################
#
# PREREQUISITES: (IMPORTANT FOR THE UNIFIED CLOUDWATCH AGENT TO INSTALL AND RUN SUCCESSFULLY)
#
# 1. must have the AWS client version 2 installed before calling this script
#    https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-windows.html
#
# 2: must have the ssm agent installed before calling this script
#    https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-install-win.html
#
# 3. Invoke this powershell script as root/administrator
#
# 4. directory c:\temp  must be created during bootup before calling this script.
#
# 5. The configuration file amazon-cloudwatch-agent.json passed as user data to the AMI must 
#    be copied/present in the c:\temp directory before calling this script
#
# 6. The EC2 instance must have a aws profile configured with the name 'AmazonCloudWatchAgent' with the 
#    access key and secret key credentials under c:\users\userid\.aws\credentials for the account
#    in which EC2 instance runs (before calling this script)
#  
# 7. The EC2 instance must have a instance profile/role attached to write to the cloudwatch with the
#    below policy. This can be profisioned during EC2 creation by the terraform but before bootup 
#    of the EC2 instance
#
<#
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Sid": "",
                    "Effect": "Allow",
                    "Action": [
                        "logs:PutLogEvents",
                        "logs:CreateLogStream",
                        "logs:CreateLogGroup",
                        "ec2:DescribeTags",
                        "cloudwatch:PutMetricData"
                    ],
                    "Resource": "*"
                }
            ]
        }
#>
#
###########################################################################################################

# SCRIPT BEGIN

#Set unrestricted permissions for the current user to execute the script 

Set-ExecutionPolicy -ExecutionPolicy  Unrestricted -Force -Scope CurrentUser

<#
# Install prerequisite awsclient if not already present 
#  
#>
<#
   if (!(Test-Path c:\temp\AWSCLIV2.msi -PathType Leaf) ) {


        Write-host "c:\temp\AWSCLIV2.msi is not present."

        Write-host "Downloading from https://awscli.amazonaws.com/AWSCLIV2.msi";


        $parameters = @{

            Uri = 'https://awscli.amazonaws.com/AWSCLIV2.msi'

            OutFile = "c:\temp\awscliv2.msi"
        }

        Invoke-WebRequest @parameters



    } else {


        Write-host "c:\temp\AWSCLIV2.msi is already present. Continuing with installation"
           
        Write-host "Installing AWSCLIV2...."

        Set-Location -Path "c:\temp"

        Start-Process msiexec.exe -ArgumentList '/I c:\temp\AWSCLIV2.msi /norestart /passive /qn' -NoNewWindow -Wait

    }
#>


<#
#  Verifies if the cloudwatch agent already exists on the Ec2. If it does, skips installation 
#  and proceeds to start the server
#>

$software = "Amazon CloudWatch Agent";

$installed = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where { $_.DisplayName -eq $software }) -ne $null

If(-Not $installed) { 



Write-Host "'$software' is NOT installed.";



    if (!(Test-Path c:\temp\AmazonCloudWatchAgent.msi -PathType Leaf) ) {


        Write-host "c:\temp\AmazonCloudWatchAgent.msi is not present."

        Write-host "Downloading from https://s3.us-east-1.amazonaws.com/amazoncloudwatch-agent-us-east-1/windows/amd64/latest/amazon-cloudwatch-agent.msi";


         $parameters = @{

            Uri = 'https://s3.us-east-1.amazonaws.com/amazoncloudwatch-agent-us-east-1/windows/amd64/latest/amazon-cloudwatch-agent.msi'

            OutFile = "c:\temp\AmazonCloudWatchAgent.msi"



         }

   
         Invoke-WebRequest @parameters


    } else {


        Write-host "c:\temp\AmazonCloudWatchAgent.msi is already present. Continuing with installation"

    }



    Write-host "Installing the Cloud Watch Agent"



    Set-Location -Path "c:\temp"



    Start-Process msiexec.exe -ArgumentList '/I c:\temp\AmazonCloudWatchAgent.msi /norestart /passive /qn' -NoNewWindow -Wait

 

    Write-host "Add configured aws profile 'AmazonCloudWatchAgent' to the Cloudwatch Agent configuration file "

    

    Add-Content C:\ProgramData\Amazon\AmazonCloudWatchAgent\common-config.toml "[credentials]"

    Add-Content C:\ProgramData\Amazon\AmazonCloudWatchAgent\common-config.toml 'shared_credential_profile = "AmazonCloudWatchAgent"'



} else {


    Write-Host "'$software' is already installed. Continuing..."

}

 

# Copy the configuration file to the cloud watch agent installation folder

#Caller aplications - copy the cloudwatch_agent.json to c:\temp folder



# Start the cloudwatch agent
    

Write-host "Starting the Cloud Watch Agent"

Set-Location -Path "C:\Program Files\Amazon\AmazonCloudWatchAgent"
    
# Add the below line to the boot script
.\amazon-cloudwatch-agent-ctl.ps1 -a fetch-config -m ec2 -c file:'C:\temp\cloudwatch_agent.json' -s



exit


# SCRIPT END


#####################################################################################################################
#
# Post installation steps:

# 1. Verify the log groups created in the Cloudwatch
#
# 2. Verify the metric group created under custom cloudwatch metrics
#
# 3. To check the status of the cloudwatch agent, issue below command from the command line.
#    & $Env:ProgramFiles\Amazon\AmazonCloudWatchAgent\amazon-cloudwatch-agent-ctl.ps1 -m ec2 -a status
# 
# 4. To stop the cloudwatch agent, issue the below command
#    & $Env:ProgramFiles\Amazon\AmazonCloudWatchAgent\amazon-cloudwatch-agent-ctl.ps1 -m ec2 -a stop
#
# 5. To start the cloudwatch agent manually, issue the below command
#    & $Env:ProgramFiles\Amazon\AmazonCloudWatchAgent\amazon-cloudwatch-agent-ctl.ps1 -a fetch-config -m ec2 \
#    -c file:'C:\temp\cloudwatch_agent.json' -s
#
#########################################################################################################################

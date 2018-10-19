#####################################################################################################################
# File Name                                                                                                         #
#   Create-ADDomain.ps1                                                                                             #
# Description                                                                                                       #
#   Script to Build a New Forest and Domain on a blank Windows Server                                               #
# Prerequisites                                                                                                     #
#   Server must have an additional disk available minimum size 60 GB                                                #
#   Server should have static IP Address                                                                            #
# Usage                                                                                                             #
#   Copy and paste script in to PowerShell window localy in the virtual machie                                      #
#   Will need to save the AD Safe mode password somewhere                                                           #
# Scope                                                                                                             #
#   Server must be minimum Windows Server 2012 R2                                                                   #
#   Blank server with  disks attached, second disk must be < 60 GB                                                  #
# Change Control                                                                                                    #
#   Andy Ferguson 18/04/2018 Initial Version                                                                        #
# To Do                                                                                                             #
#                                                                                                                   #
# Source info                                                                                                       #
#                                                                                                                   #
#####################################################################################################################

# Variables that can be changed to suit
# NETBIOS Name for the Domain
$Domain = "Domain"
# DNS Domain Name will append .loc for the DNS name ammend to suit
$DomainFQDN = "$Domain.loc"

#Get-WindowsFeature
# Install Feature
Install-WindowsFeature AD-Domain-Services,GPMC,RSAT-AD-Tools
# Create new partitions for SYSVol AD Logs and Database
Get-Disk | Where-Object PartitionStyle -Eq "RAW" | Initialize-Disk
$SysvolDisk = New-Partition -DiskNumber 2 -Size 20GB -AssignDriveLetter | Format-Volume -FileSystem NTFS -NewFileSystemLabel SYSVOL -Confirm -Force
New-Partition -DiskNumber 2 -Size 20GB -DriveLetter "L" | Format-Volume -FileSystem NTFS -NewFileSystemLabel ADLogs -Confirm -Force
New-Partition -DiskNumber 2 -UseMaximumSize -DriveLetter "S" | Format-Volume -FileSystem NTFS -NewFileSystemLabel ADDB -Confirm -Force

#New-Partition -DiskNumber 2 -Size 
#Get-Partition -DiskNumber "2" -PartitionNumber "2" | Remove-Partition -Confirm $true

$SysvolPath = $SysvolDisk.DriveLetter + ':\SYSVOL'
Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath "S:\NTDS" -DomainMode "7" -DomainName "$DomainFQDN" -DomainNetbiosName "$Domain" `
 -ForestMode "7" -InstallDns:$true -LogPath "L:\NTDS" -NoRebootOnCompletion:$false -SysvolPath "$SysvolPath" -Force:$true

#Add Safe Mode Admin password to pop up box

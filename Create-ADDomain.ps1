#####################################################################################################################
# File Name                                                                                                         #
#   Create-ADDomain.ps1                                                                                            #
# Description                                                                                                       #
#   Script to Build a Windows domain controller froma a blank VM                                                    #
# Usage                                                                                                             #
#   Copy and paste script in to PowerShell window localy in the virtual machie                                      #
#   Will need to save the AD Safe mode password somewhere                                                           #
# Scope                                                                                                             #
#   Server must be minimum 2012 R2                                                                                  #
#   Blank server with  disks attached, second disk must be < 60 GB                                                  #
# Change Control                                                                                                    #
#   Andy Ferguson 18/04/2018 Initial Version                                                                        #
# To Do                                                                                                             #
# 
# Source info
#
#####################################################################################################################

#Get-WindowsFeature
Install-WindowsFeature AD-Domain-Services,GPMC,RSAT-AD-Tools
Get-Disk | Where-Object PartitionStyle -Eq "RAW" | Initialize-Disk
$SysvolDisk = New-Partition -DiskNumber 2 -Size 20GB -AssignDriveLetter | Format-Volume -FileSystem NTFS -NewFileSystemLabel SYSVOL -Confirm -Force
New-Partition -DiskNumber 2 -Size 20GB -DriveLetter "L" | Format-Volume -FileSystem NTFS -NewFileSystemLabel SYSVOL -Confirm -Force
New-Partition -DiskNumber 2 -UseMaximumSize -DriveLetter "S" | Format-Volume -FileSystem NTFS -NewFileSystemLabel SYSVOL -Confirm -Force

#New-Partition -DiskNumber 2 -Size 


#Get-Partition -DiskNumber "2" -PartitionNumber "2" | Remove-Partition -Confirm $true

$Domain = "Domain"
$SysvolPath = $SysvolDisk.DriveLetter + ':\SYSVOL'
Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath "S:\NTDS" -DomainMode "7" -DomainName "$Domain.loc" -DomainNetbiosName "$Domain" `
 -ForestMode "7" -InstallDns:$true -LogPath "L:\NTDS" -NoRebootOnCompletion:$false -SysvolPath "$SysvolPath" -Force:$true

 #Add Safe Mode Admin password
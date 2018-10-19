#####################################################################################################################
# File Name                                                                                                         #
#   Export-ADOrganizationalUnits.ps1                                                                                #
# Description                                                                                                       #
#   Script to Extract AD Organiationa Units from an AD Domain recursively used to transfer OU Structures between    #
#   AD Domains to ensure uniform set up of an OU structure                                                          #
#   Ensures all rules are given a unique Priority                                                                   #
# Usage                                                                                                             #
#   Copy and paste script in to PowerShell window whilst connected to a Server as a domain admin                    #
#   Used the with the Export XML created on the desktop and the Create-ADOrganizationalUnits.ps1 in target domain to#
#   recreate the AD Strucure of the Source Domain. Does not overwrite existing OU structure in a Domain, risk of    #
#   execution is minimal but a large manual clean up of the AD Organisational units will be required.               #                     
# Prerequisite                                                                                                      #
#   You must have the ADGroups-Export All Default.xml file with all the groups from a default AD Domain             #  
# Scope                                                                                                             #
#   Server 2012 R2 and above                                                                                        #
# Change Control                                                                                                    #
#   Andy Ferguson 17/10/2018 Initial Version                                                                        #
# To Do                                                                                                             #
#   Strip the domain from the DistinguishedName so its universal                                                    #
#####################################################################################################################
#https://www.petri.com/powershell-problem-solver-exporting-active-directory-groups-csv

# Working bit
# Exports all groups members and members of 
# To be run on the server to 

$Profile = $env:USERPROFILE

Get-ADOrganizationalUnit -filter "*" -Properties Description | Select-Object Name,DistinguishedName,Description | Export-CliXML -Path "$Profile\desktop\ADOrganizationalUnits-Export.xml" 

#Exports all OUs to XML
#Export-CliXML -Path "$Profile\desktop\ADGroups-Export.xml"
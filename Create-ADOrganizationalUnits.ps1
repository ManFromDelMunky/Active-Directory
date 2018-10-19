#####################################################################################################################
# File Name                                                                                                         #
#   Export-ADOrganizationalUnits.ps1                                                                                #
# Description                                                                                                       #
#   Script to Create AD Organizational Units for a new Domain use with the Export-ADOrganizationalUnits.ps1 to      #
#   Export a source AD Domain to ensure uniform set up of an OU structure                                           #
# Usage                                                                                                             #
#   Copy and paste script in to PowerShell window whilst connected to a Server as a domain admin                    #
#   Used the with the Export XML created on the desktop and the Export-ADOrganizationalUnits.ps1 in target domain to#
#   recreate the AD Strucure of the Source Domain. Does not overwrite existing OU structure in a Domain, risk of    #
#   execution is minimal but a large manual clean up of the AD Organisational units will be required.               #                     
# Prerequisite                                                                                                      #
#   You must have the ADOrganizationalUnits-Export.xml file with all the OUs from a source AD Domain or use a       #  
#	default one from the import directory																			#
# Scope                                                                                                             #
#   Server 2012 R2 and above                                                                                        #
# Change Control                                                                                                    #
#   Andy Ferguson 19/10/2018 Initial Version                                                                        #
# To Do                                                                                                             #
#   Strip the domain from the DistinguishedName so its universal                                                    #
#####################################################################################################################

# Working bit
# Get Date to append to descriptions and files
$Date = get-date -uformat "%Y %m %d"
#Do Local Domain
$DomainInfo = Get-ADDomain
$DomainDistinguishedName = $DomainInfo.DistinguishedName
$PDCEmulator = $DomainInfo.PDCEmulator
# Import csv list or OU's and containers
$Groups = Import-CliXML -Path "$Profile\desktop\ADOrganizationalUnits-Export.xml"
#Create all thw OU's
Foreach ($Group in $Groups)
{
	$GroupName = $Group.Name
	$GroupDescription = $Group.Description
	$GroupTrim = "OU=" + "$GroupName" + ","
	# Trim the old domain and the OU Name from the DN in the import
	$GroupNonDomainRelativeDN = $Group.DistinguishedName.Replace('DC=delmunky,DC=loc','')
	$GroupNonDomainRelativeDN = $GroupNonDomainRelativeDN.Replace("$GroupTrim",'')
    # Replaces the old Domain DN with the new Domain DN
	$GroupDistinguishedName = $GroupNonDomainRelativeDN += $DomainDistinguishedName

	# Creates the OU
	New-ADOrganizationalUnit -Name $GroupName -Description $GroupDescription -Path $GroupDistinguishedName -Server $PDCEmulator -ProtectedFromAccidentalDeletion $true
	# Clear any variables ready for the next OU
	Clear-Variable -Name GroupNonDomainRelativeDN
	Clear-Variable -Name GroupDistinguishedName
	Clear-Variable -Name GroupName
	Clear-Variable -Name GroupDescription
}

# As all OU's are created and protected from deletion this command ma be useful to delete any OU's you dont want after creation
## Get-ADOrganizationalUnit -filter * | Set-ADObject -ProtectedFromAccidentalDeletion:$false

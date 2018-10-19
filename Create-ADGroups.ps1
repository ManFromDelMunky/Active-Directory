#####################################################################################################################
# File Name                                                                                                         #
#   Create-ADGroups.ps1                                                                                             #
# Description                                                                                                       #
#   Script to create AD Groups from Export AD Groups and membership from all AD Groups           					#
#   used to check AD Group Nesting                                                                                  #
# Pre requisites																									#
#	Required the Domain OU structure be set up with Create-ADOrganisationalUnits Script								#
# Usage                                                                                                             #
#   Copy and paste script in to PowerShell window whilst connected to a Server as a domain admin                    #
#   Input                                                                                                           #
#       XML created by Export-ADGroups.ps1										                                    #
#   Permisions																										#
#       Domain Administrator permisions required																	#
# Scope                                                                                                             #
#   Server 2008 R2 and above                                                                                        #
# Change Control                                                                                                    #
#   Andy Ferguson 19/02/2018 Initial Version                                                                        #
# To Do                                                                                                             #
#   Strip the domain from the DistinguishedName so its universal                                                    #
#####################################################################################################################

$Profile = $env:userprofile
$Groups = Import-CliXML -Path "$Profile\desktop\ADGroups-Export.xml"
$Domaininfo = Get-ADDomain
$PDCE = $Domaininfo.PDCEmulator
$DistinguishedName = $Domaininfo.DistinguishedName
# Create all groups
Foreach ($Group in $Groups)
{
	$GroupScope = $Group.GroupScope.ToString()
	$GroupCategory = $Group.GroupCategory
	$GroupName = $Group.SamAccountName
	$GroupDescription = $Group.Description
	
	If ($GroupScope -eq "Global")
	{
		$DestinationOU = 'OU=Global Groups,OU=Domain Groups,'
		$DNPath = "$DestinationOU" + "$DistinguishedName"
	}
		
	ElseIf ($GroupScope -eq "DomainLocal")
	{
		$DestinationOU = "OU=Domain Local Groups,OU=Domain Groups,"
		$DNPath = "$DestinationOU" + "$DistinguishedName"
	}

	ElseIf ($GroupScope -eq "Universal")
	{
		If ($GroupCategory -eq "Distribution")
		{
			$DestinationOU = "OU=Distribution Lists,OU=Domain Groups,"
			$DNPath = "$DestinationOU" + "$DistinguishedName"
		}
		If ($GroupCategory -eq "Security")
		{
			$DestinationOU = "OU=Global Groups,OU=Domain Groups,"
			$DNPath = "$DestinationOU" + "$DistinguishedName"
		}
	}
	New-ADGroup -Name $GroupName -GroupScope $GroupScope -GroupCategory $GroupCategory -Description $GroupDescription -Path $DNPath -Server $PDCE
# Close Create all groups
}	
# Create all the members links


Foreach ($Group in $Groups)
{
	If (($Group.Members.Count) -gt "0" )
	{
        $PrimaryGroupName = $Group.SamAccountName.ToString()
		$PrimaryGroup = Get-ADGroup -Identity "$PrimaryGroupName"
        $PrimaryGroupName
		$Members = $Group.Members
        #$Members
		Foreach ($SubGroup in $Members)
		{
            #$SubGroup | Get-Member
            $SubMemberName = $SubGroup.ToString()
			$SubMember = Get-ADGroup -Identity $SubMemberName
			Add-ADGroupMember -Identity $PrimaryGroup -Members $SubMember
		}	
	}

}

# Close Create all the members links
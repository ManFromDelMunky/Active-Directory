#####################################################################################################################
# File Name                                                                                                         #
#   Export-ADGroups.ps1                                                                                             #
# Description                                                                                                       #
#   Script to Extract AD Groups and membership from all AD Groups used to check AD Group Nesting                    #
#   Ensures all rules are given a unique Priority                                                                   #
# Usage                                                                                                             #
#   Copy and paste script in to PowerShell window whilst connected to a Server as a domain admin                    #
#   Second part of the script is run on a desktop with both files and creates a delta between a default AD and your #
#   AD                                                                                                              #
#   Script performs Get only so risk of execution is minimal                                                        #
# Prerequisite                                                                                                      #
#   You must have the ADGroups-Export All Default.xml file with all the groups from a default AD Domain             #  
# Scope                                                                                                             #
#   Server 2012 R2 and above                                                                                        #
# Change Control                                                                                                    #
#   Andy Ferguson 05/02/2018 Initial Version                                                                        #
# To Do                                                                                                             #
#####################################################################################################################
#https://www.petri.com/powershell-problem-solver-exporting-active-directory-groups-csv

# Working bit
# Exports all groups members and members of 
# To be run on the server to 

$Profile = $env:USERPROFILE

Get-ADGroup -filter "*" -Properties MemberOf,Members | Select-Object SamAccountName,GroupCategory,DistinguishedName,Description,GroupScope,SID,MemberOf,Members | Export-CliXML -Path "$Profile\desktop\ADGroups-Export.xml"   

#Exports to XML and keeps sub array in Members
#Export-CliXML -Path "$Profile\desktop\ADGroups-Export.xml"

#Second part to be run on a desktop or server with the ADGroups-Export All Default.xml baseline.
# Make a new array with only the groups that have been added not the groups that come as default in a Domain
$Profile = "$env:USERPROFILE\OneDrive\Programing\PowerShell"
$ImportXML = Import-CliXML -Path "$Profile\Import\ADGroups-Export All Groups.xml"
$ImportDefaultGroupsXML = Import-CliXML -Path "$Profile\Import\ADGroups-Export All Default.xml"

$CustomADGroups =@()
ForEach($Group in $ImportXML)
{
    $SamAccountName = $Group.SamAccountName
    $SamAccountName
    ($ImportDefaultGroupsXML.SamAccountname) -notcontains $SamAccountName
    if((($ImportDefaultGroupsXML.SamAccountname) -notcontains $SamAccountName) -eq $true)
    {
        Write-Host "Yup"
        $_
        $CustomADGroups = $CustomADGroups += $Group
    }
}

#Exports to XML and keeps sub array in Members
$CustomADGroups | Export-CliXML -Path "$Profile\Import\ADGroups-Export Custom.xml"

# ReImports as Deserialized.System.Object
$ImportXML = Import-CliXML -Path "$Profile\desktop\ADGroups-Export Custom.xml"

#S C:\Users\2016DC1> $ImportXML | Get-Member
#
#
#   TypeName: Deserialized.System.Object
#
#Name              MemberType   Definition                                                                                                              
#----              ----------   ----------                                                                                                              
#Equals            Method       bool Equals(System.Object obj)                                                                                          
#GetHashCode       Method       int GetHashCode()                                                                                                       
#GetType           Method       type GetType()                                                                                                          
#ToString          Method       string ToString(), string ToString(string format, System.IFormatProvider formatProvider), string IFormattable.ToStrin...
#DistinguishedName NoteProperty string DistinguishedName=CN=Denied RODC Password Replication Group,CN=Users,DC=delmunky,DC=loc                          
#GroupCategory     NoteProperty Deserialized.Microsoft.ActiveDirectory.Management.ADGroupCategory GroupCategory=Security                                
#GroupScope        NoteProperty Deserialized.Microsoft.ActiveDirectory.Management.ADGroupScope GroupScope=DomainLocal                                   
#MemberOf          NoteProperty Deserialized.Microsoft.ActiveDirectory.Management.ADPropertyValueCollection MemberOf=                                   
#MemberOfCount     NoteProperty int MemberOfCount=0                                                                                                     
#Members           NoteProperty Deserialized.Microsoft.ActiveDirectory.Management.ADPropertyValueCollection Members=CN=Read-only Domain Controllers,C...
#MembersCount      NoteProperty int MembersCount=8                                                                                                      
#SamAccountName    NoteProperty string SamAccountName=Denied RODC Password Replication Group                                                            
#SID               NoteProperty Deserialized.System.Security.Principal.SecurityIdentifier SID=S-1-5-21-2216623672-3790881700-714008327-572              

#Close Working bit

# Random snipits
# use later to rehydrate variables
$Profile = $env:USERPROFILE
$DomainLocalGroups = Get-ADGroup -filter "*" -Properties MemberOf,Members
$GroupArrayPlus = @()
ForEach ($LocalGroup in $DomainLocalGroups)
    {
    # Create New array with the Domain entries in
    $GroupArray = New-Object System.Object
    $GroupArray | Add-Member -type NoteProperty -name SamAccountName -value $LocalGroup.SamAccountName
    $GroupArray | Add-Member -type NoteProperty -name GroupCategory -value $LocalGroup.GroupCategory
    $GroupArray | Add-Member -type NoteProperty -name DistinguishedName -value $LocalGroup.DistinguishedName
    $GroupArray | Add-Member -type NoteProperty -name GroupScope -value $LocalGroup.GroupScope
    $GroupArray | Add-Member -type NoteProperty -name SID -value $LocalGroup.SID
    $GroupArray | Add-Member -type NoteProperty -name MemberOf -value $LocalGroup.MemberOf
    $GroupArray | Add-Member -type NoteProperty -name MemberOfCount -value $LocalGroup.MemberOf.count
    $GroupArray | Add-Member -type NoteProperty -name Members -value $LocalGroup.Members
    $GroupArray | Add-Member -type NoteProperty -name MembersCount -value $LocalGroup.Members.count
    $GroupArrayPlus += $GroupArray
    }
$GroupArrayPlus | Export-CliXML -Path "$Profile\desktop\ADGroups-Export.xml"   



Get-ADGroup -filter "Groupcategory -eq 'Security' -AND GroupScope -eq 'DomainLocal' -AND Member -like '*'" |
foreach { 
Get-ADGroupMember -Identity $_. | 
Get-ADGroup | Select-Object DistinguishedName,GroupCategory,GroupScope,Name,SamAccountName

}

# use later to rehydrate variables close


$groups = Get-Content c:\temp\Groups.txt            
            
foreach($Group in $Groups) {            
            
Get-ADGroupMember -Id $Group | select  @{Expression={$Group};Label="Group Name"},* | Export-CSV c:\temp\GroupsInfo.CSV -NoTypeInformation -Append
            
}

get-adgroup -filter * -properties Member| select Name,DistinguishedName,
GroupCategory,GroupScope,@{Name="Members";
Expression={( $_.members | Measure-Object).count}} |
Out-GridView

$DomainLocalGroups = Get-ADGroup -filter "Groupcategory -eq 'Security' -AND GroupScope -eq 'DomainLocal' -AND Member -like '*'"



# Adapted array maker
$DomainLocalGroups = Get-ADGroup -filter "Groupcategory -eq 'Security' -AND GroupScope -eq 'DomainLocal' -AND Member -like '*'" -Properties MemberOf,Members
$GroupArrayPlus = @()
ForEach ($LocalGroup in $DomainLocalGroups)
    {
    # Create New array with the Domain entries in
    $GroupArray = New-Object System.Object
    $GroupArray | Add-Member -type NoteProperty -name SamAccountName -value $LocalGroup.SamAccountName
    $GroupArray | Add-Member -type NoteProperty -name GroupCategory -value $LocalGroup.GroupCategory
    $GroupArray | Add-Member -type NoteProperty -name DistinguishedName -value $LocalGroup.DistinguishedName
    $GroupArray | Add-Member -type NoteProperty -name GroupScope -value $LocalGroup.GroupScope
    $GroupArray | Add-Member -type NoteProperty -name SID -value $LocalGroup.SID
    $GroupArray | Add-Member -type NoteProperty -name MemberOf -value $LocalGroup.MemberOf
    $GroupArray | Add-Member -type NoteProperty -name MemberOfCount -value $LocalGroup.MemberOf.count
    $GroupArray | Add-Member -type NoteProperty -name Members -value $LocalGroup.Members
    $GroupArray | Add-Member -type NoteProperty -name MembersCount -value $LocalGroup.Members.count
    $GroupArrayPlus += $GroupArray
    }
$GroupArrayPlus | Export-CliXML -Path "$Profile\desktop\ADGroups-Export.xml"   

$EPMOAndDomain = @()
ForEach ($EPMOUser in $EPMOPlusDomain)
{
    $FirstName = $EPMOUser.FirstName
    # Search each AD
    #NNTHA
    $ADUserAccount = Get-ADUser -SearchBase "OU=Users_OU,DC=nntha,DC=loc" -SearchScope Subtree -Filter {(GivenName -eq $FirstName) -and (Surname -eq $LastName)} -Properties * -Server PDCDCR01v.nntha.loc #| Set-ADUser -Add @{EmployeeID="$EmployeeID"} -Server PDCDCR01v.nntha.loc
    $NumberOfUsers = $ADUserAccount.count
    If (($ADUserAccount.SamAccountName) -ne $null)
        {
        $ADUsername = $ADUserAccount.SamAccountName
        Write-Output "User found $ADUsername"
        $EPMOUser.SamAccountName = $ADUsername
        $EPMOUser.NNTHA = $true
        $EPMOUser.DomainCount +=1
        }
    If (($ADUserAccount.count) -gt "1")
        {
        Write-Output "More than one user account found for $EPMOUsername"
        $EPMOUser.MultipleAccountsNNTHA = $true
        $EPMOUser.NNTHA = $true
        }

        $EPMOAndDomain += $EPMOUser
}
$EPMOAndDomain | Export-Csv W:\LogFiles\EPMOAndDomain.csv -NoTypeInformation



#from server



Get-ADGroupMember "LAG_SCCM_Administrators" -Recursive


get-adgroup -filter * -properties Member | Select-Object Name,DistinguishedName GroupCategory,GroupScope,@{Name="Members"; Expression={( $_.members | Measure-Object).count}} | Out-GridView


get-adgroup -filter * -properties Member| select Name,DistinguishedName,
GroupCategory,GroupScope,@{Name="Members";
Expression={( $_.members | Measure-Object).count}} |
Out-GridView


$Profile = $env:USERPROFILE
Get-ADGroup -filter "Groupcategory -eq 'Security' -AND GroupScope -ne 'DomainLocal' -AND Member -like '*'" |
foreach { 
 Write-Host "Exporting $($_.name)" -ForegroundColor Cyan
 $name = $_.name -replace " ","-"
 $file = Join-Path -path "$Profile\desktop" -ChildPath "$name.csv"
 Get-ADGroupMember -Identity $_.distinguishedname -Recursive |  
 Get-ADObject -Properties SamAccountname,Title,Department |
 Select Name,SamAccountName,Title,Department,DistinguishedName,ObjectClass |
 Export-Csv -Path $file -NoTypeInformation
}


Get-ADGroup -Identity "LAG_SCCM_Administrators" -Properties *

Get-ADGroupMember -Identity "LAG_SCCM_Administrators" | 
Get-ADGroup | Select-Object DistinguishedName,GroupCategory,GroupScope,Name,SamAccountName |
Export-CliXML -Path "$Profile\desktop\LAG_SCCM_Administrators.xml"




[xml]$Import = Get-Content -Path "$Profile\desktop\LAG_SCCM_Administrators.xml"



Get-ADGroup -filter "*" |
foreach { 
Get-ADGroupMember -Identity "LAG_SCCM_Administrators" | 
Get-ADGroup | Select-Object DistinguishedName,GroupCategory,GroupScope,Name,SamAccountName,Members,MemberOf 

}
Export-CliXML -Path "$Profile\desktop\ADGroups-Export.xml"
$ImportXML = Import-CliXML -Path "$Profile\desktop\ADGroups-Export.xml"
[xml]$Import = Get-Content -Path "$Profile\desktop\ADGroups-Export.xml"
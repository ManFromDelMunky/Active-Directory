#####################################################################################################################
# File Name                                                                                                         #
#   Diagram-ADGroups.ps1                                                                                            #
# Description                                                                                                       #
#   Script to Diagram AD Groups and membership in Visio from all AD Groups used to check AD Group Nesting           #
#   Use with Export-ADGroups output to get all AD Groups and their nesting                                          #
# Usage                                                                                                             #
#   Copy and paste script in to PowerShell window whilst on system with Visio Installed                             #
#   Script performs Get only so risk of execution is minimal                                                        #
# Scope                                                                                                             #
#   System must have Visio installed                                                                                #
# Change Control                                                                                                    #
#   Andy Ferguson 05/02/2018 Initial Version                                                                        #
# To Do                                                                                                             #
#####################################################################################################################

# Working bit
# Set Visio application and save location
$Application = New-Object -ComObject Visio.Application 
$Documents = $Application.Documents
$Document = $Documents.Add("ACTDIR_M.VSTX")
$Pages = $Application.ActiveDocument.Pages
$Page = $Pages.Item(1)
#$Stencil = $Application.Documents.Add("Basic Shapes.vss")
$StencilPath='C:\Program Files (x86)\Microsoft Office\Office15\Visio Content\1033'
#$Stencil = $Visio.Documents.Add($stencilPath,64)
$Stencil = $Application.Documents.OpenEx("$StencilPath\ADO_M.VSSX",64)
#$Profile = $env:USERPROFILE
$Profile = "$env:USERPROFILE\OneDrive\Programing\PowerShell"

#Import Groups
$Grouplist = Import-CliXML -Path "$Profile\Import\ADGroups-Export Custom.xml"
#$Grouplist = Import-CliXML -Path "$Profile\Import\ADGroups-Export All Groups.xml"
# Set position
$XCoordinate = 1
$YCoordinate = 1

foreach($Group in $Grouplist)
{
    #Draw all object
    $SamAccountName = $Group.SamAccountName
    $Item = $Stencil.Masters.Item("Group")
    $Shape = $Page.Drop($item, ($XCoordinate), ($YCoordinate))
    $Shape.Text = "$SamAccountName" 
    #$Stencil=$Documents.OpenEx($StencilPath,64)
    If($XCoordinate -lt 7)
   {
        $XCoordinate = $XCoordinate += 1
    }
   else
   {
        $XCoordinate = 1
        $YCoordinate = $YCoordinate += 1
   }
    
}

#Loop that will go through each shape on the page and create array
$PageObjectArray = New-Object System.Object
$PageObjectArray = @()
$ObjectArray = @()
ForEach ($VisioShape In ($application.activepage.shapes)) 
{
    $ObjectArray = New-Object System.Object
    $ObjectArray | Add-Member -type NoteProperty -name ShapeName -value $VisioShape.Text
    $ObjectArray | Add-Member -type NoteProperty -name ShapeNumber -value $VisioShape.NavigationIndex
    $PageObjectArray = $PageObjectArray += $ObjectArray
}

# Second pass to add links between all members and memberof
ForEach($Group in $Grouplist)
{
    If(($Group.MemberOf.count) -gt "0")
    {    
        # Get the PrimaryGroup Object in Visio
        ForEach($Find in $PageObjectArray)
        {
            if(($Find.ShapeName) -eq ($Group.SamAccountName))
            {
                #$Group.SamAccountName
                $PrimaryShapeNumber = $Find.ShapeNumber
                $PrimaryGroup = $application.activepage.shapes.Item($PrimaryShapeNumber)
            }
                
        }        
        #Get the Members of the group
        $MembersOfGroup = $Group.MemberOf
        # Loop through all the members
        foreach($Members in $MembersOfGroup)
        {
            # Use the Group list to get the Members SamAccountName from the DN in the Members property
            ForEach($Group in $Grouplist)
            {
                if(($Group.DistinguishedName) -eq ($Members))
                {
                    $MembersSamAccountName = $Group.SamAccountName
                }
            }
            # Get the MemberGroup Object in Visio
            ForEach($Find in $PageObjectArray)
            {
                #$MembersSamAccountName
                if(($Find.ShapeName) -eq ($MembersSamAccountName))
                {
                    $MemberShapeNumber = $Find.ShapeNumber
                    #$MemberShapeNumber
                    $MemberGroup = $application.activepage.shapes.Item($MemberShapeNumber)
                }
                
            }
            #Draw the link
            $PrimaryGroup.AutoConnect($MemberGroup,0)
            #
        }
    }
}



# Resize to fit page
$application.activepage.ResizeToFitContents()
$application.activepage.AutoSizeDrawing()

#$document.SaveAs("$Profile\Desktop\MyADGroupDrawing.vsdx")
#$application.Quit()
# Close Working bit

# Scratch


#Tofind ShapeNumber
ForEach($Find in $PageObjectArray)
{
    if(($Find.ShapeName) -eq ($Group.SamAccountName))
    {
    $ShapeNumber = $Find.ShapeNumber    
    }
    
}


#get master, if Server or Router, then do an NSlookup of the name and apply the resultant IP address to the shape in question
If($master.name -eq "Server" -or $master.name -eq "Router 1")
{
    $networkname = $vsoshape.cells("Prop.NetworkName").ResultStr(0)
    $ipaddress = Resolve-DnsName $networkname | select IPaddress | foreach {$_.IPaddress}
    $vsoCell = $vsoShape.Cells("Prop.IPaddress")
    $vsoCell.formula = """$ipaddress""" 
}



#Loop that will go through each shape on the page and create array
ForEach ($VisioShape In ($application.activepage.shapes)) 
{
    $Master = $VisioShape | Select-Object -expand Master
    $ShapeName = $Master.Name
    $ShapeNumber = $Master.Name
    $Group = $GroupList | Get-ChildItem | Where-Object (($_.SamAccountName) -EQ "$ShapeName")
    $Group.Members
    ForEach ($VisioShape In ($application.activepage.shapes))
    {
        $Application
    }

}


# Second pass to add all members and memberof
ForEach($Group in $Grouplist)
{
    #Get the $Group object on Visio
    $AllShapes = $application.activepage.shapes
    $PrimaryGroup = ($PageObjectArray | Where-Object (($_.ShapeName) -eq ($Group.SamAccountName))).ShapeNumber

    #Get the Members of the group
    foreach($Members in $Group)
    {
        $SubGroup = $application.activepage.shapes | Where-Object (($Member.SamAccountName) -EQ ($application.activepage.shapes.Text))
        #Draw the link
        $PrimaryGroup.AutoConnect($SubGroup,0)
    }
}

#How do use this script
#Enter parameters in Param
# $SiteUrl - the url for the sharpoint-side
#            eg. http://share.dev.local/sites/<userName" for the local sharepoint-site
#            http://sp2013.pmone.local/sites/apps     develop-machine
# $File    - path to the Share.app (fullPath including file-name)
# $DocLibName - Name of the sharepoint list where the file should be added to
#               e.g "App Packages" for the local developer site
#               "Apps for SharePoint"  develop machine
# $Credentials e.g. (new-object -typename System.Management.Automation.PSCredential -argumentlist "<userName>", (convertTo-SecureString '<pwd>' -asplaintext -force))


# settings
PARAM
(
[Parameter(Mandatory=$true)]
[string] $SiteURL = "http://share.dev.local/sites/<user>",
[Parameter(Mandatory=$true)]
[string] $File = "C:\development\<test>.app",
[Parameter(Mandatory=$true)]
[string] $DocLibName = "App Packages",
$Credentials = $null
)

#Add references to SharePoint client assemblies and authenticate to Office 365 site – required for CSOM
try
{

    Add-Type -Path ($PSScriptRoot + "\Microsoft.SharePoint.Client.dll")
    Add-Type -Path ($PSScriptRoot + "\Microsoft.SharePoint.Client.Runtime.dll")
}
catch
{
    # type already installed
}


#Bind to site collection
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)

#Load Cretentials
if ($Credentials)
{
    $Context.Credentials = $Credentials
}
else
{
#Load Default Credentials
    $Context.Credentials = [System.Net.NetworkCredential]::("USERNAME", (ConvertTo-SecureString "PASSWORD" -AsPlainText -force)) 
}


#Retrieve list
$List = $Context.Web.Lists.GetByTitle($DocLibName)
$Context.Load($List)
$Context.ExecuteQuery()


#Upload file
if (Test-Path $File)
{
    $fileItem = Get-ChildItem $File
    $FileStream = New-Object IO.FileStream($File,[System.IO.FileMode]::Open)
    $FileCreationInfo = New-Object Microsoft.SharePoint.Client.FileCreationInformation
    $FileCreationInfo.Overwrite = $true
    $FileCreationInfo.ContentStream = $FileStream
    $FileCreationInfo.URL = $fileItem.Name
    $Upload = $List.RootFolder.Files.Add($FileCreationInfo)
    $Context.Load($Upload)
    $Context.ExecuteQuery()
    $FileStream.Close()
}
else
{
   "File not found"
}

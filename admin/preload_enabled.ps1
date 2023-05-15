### Enable if required
#Import-Module ServerManager
#Add-WindowsFeature Web-Scripting-Tools
Import-Module WebAdministration


#Set the site name
$siteName = "Default Web Site"

<#
    Enable Application Initialization
#>

#Ensure Application Initialization is available
$webAppInit = Get-WindowsFeature -Name "Web-AppInit"

if(!$webAppInit.Installed) 
{
    Write-Host "$($webAppInit.DisplayName) not present, installing"
    Install-WindowsFeature $webAppInit -ErrorAction Stop
    Write-Host "`nInstalled $($webAppInit.DisplayName)`n" -ForegroundColor Green
}
else 
{
    Write-Host "$($webAppInit.DisplayName) was already installed" -ForegroundColor Yellow
}

#Fetch the site
$site = Get-Website -Name $siteName

if(!$site)
{
    Write-Host "Site $siteName could not be found, exiting!" -ForegroundColor Yellow
    Break
}


#Fetch the application pool
$appPool = Get-ChildItem IIS:\AppPools\ | Where-Object { $_.Name -eq $site.applicationPool }


#Set up AlwaysRunning
if($appPool.startMode -ne "AlwaysRunning")
{
    Write-Host "startMode is set to $($appPool.startMode ), activating AlwaysRunning"
    
    $appPool | Set-ItemProperty -name "startMode" -Value "AlwaysRunning"
    $appPool = Get-ChildItem IIS:\AppPools\ | Where-Object { $_.Name -eq $site.applicationPool }

    Write-Host "startMode is now set to $($appPool.startMode)`n" -ForegroundColor Green
} 
else 
{
    Write-Host "startMode was already set to $($appPool.startMode) for the application pool $($site.applicationPool)" -ForegroundColor Yellow
}


<#
    Enable preloadEnabled on the IIS Site instance
#>


if(!(Get-ItemProperty "IIS:\Sites\$siteName" -Name applicationDefaults.preloadEnabled).Value) 
{
    Write-Host "preloadEnabled is inactive, activating"
    
    Set-ItemProperty "IIS:\Sites\$siteName" -Name applicationDefaults.preloadEnabled -Value True
    
    Write-Host "preloadEnabled is now set to $((Get-ItemProperty "IIS:\Sites\$siteName" -Name applicationDefaults.preloadEnabled).Value)" -ForegroundColor Green
} 
else
{
    Write-Host "preloadEnabled already active" -ForegroundColor Yellow
}

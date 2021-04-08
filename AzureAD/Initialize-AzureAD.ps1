 <#
    .SYNOPSIS
        AzureAD Powershell Session 활성화
    .DESCRIPTION
        AzureAD Powersehll 모듈 인스톨 및 세션 활성화 
    .PARAMETER Credential
        Azure AD 접속 인증정보
    .OUTPUTS
        None
    .EXAMPLE
        Initialize-AzureADPowerShell
#>

[CmdletBinding()]
param (

    [Parameter()]
    [System.Management.Automation.PSCredential]
    $Credential
)

function Test-Administrator  
{  
    [OutputType([bool])]
    param()
    process {
        [Security.Principal.WindowsPrincipal]$user = [Security.Principal.WindowsIdentity]::GetCurrent();
        return $user.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator);
    }
}


function Test-AzureADConnection
{
    try
    {
        $azureADSessionInfo = Get-AzureADCurrentSessionInfo -ErrorAction SilentlyContinue
        if (($azureADSessionInfo -notlike $null) -and ($azureADSessionInfo.TenantId -notlike $null))
        {
            $true
        }
        else
        {
            $false
        }
    }
    catch
    {
      #  Write-Log -Level "WARNING" -Activity $activity -Message "Failed to run Get-AzureADCurrentSessionInfo to check for existing sessions."
        $false
    }
}


[bool]$connectedToAzureAD = $false
$activity = "Initialize AzureAD PowerShell"
#Clear-Host 
Write-Host  "Initializing AzureAD Powershell.  Please provide adminsitrator access if prompted." -ForegroundColor Green 
#Write-Log -Level "INFO" -Activity $activity -Message "Initializing AzureAD Powershell.  Please provide adminsitrator access if prompted." -WriteProgress
    
$existingModules = Get-Module -ListAvailable -Name "AzureAD"
    
if ($existingModules.Count -like 0)
{
    if ($PSVersionTable.PSVersion.Major -ge 5)
    {
        try
        {
            if(-not (Test-Administrator))
            {                
                Write-Host "This script must be executed as Administrator." -ForegroundColor Red                
                return
            }
            
            Write-Host "Installing the AzureAD Powershell Module." -ForegroundColor Green            
            Install-Module azuread -Confirm:$false -Scope CurrentUser -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -Force | Out-Null
        }
        catch
        {
            Write-Host "Failed to install the Azure AD PowerShell Module. $($_.Exception.Message)" -ForegroundColor Red             
            return
        }
    }
    else
    {
        Write-Host "Azure AD Discovery skipped due to missing PowerShell Module.  Could not use Install-Module due to PowerShell Version." -ForegroundColor Red             
        
        return
    }
}

if ($Credential -like $null)
{
    Write-Host "Prompting for Azure AD Credentials"       
    $Credential = Get-Credential -Message "Azure AD PowerShell admin credentials"
}
    
try
{
    Connect-AzureAD -Credential $Credential
}
catch
{
    if ($_.Exception.Message -like '*multi-factor*')
    {
        Write-Host "Failed to pass credentials to Azure AD Module due to MFA Requirements.  Provide credentials when prompted." -ForegroundColor Green                    
        Connect-AzureAD
    }
}

if (Test-AzureADConnection)
{
    Write-Host "Successfully connected AzureAD PowerShell." -ForegroundColor Green    
    $connectedToAzureAD = $true
}
else
{
    Write-Host "Failed to connect AzureAD PowerShell." -ForegroundColor Yellow
    
}





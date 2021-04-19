<# 
.SYNOPSIS
    사서함 이관 상태 확인
.DESCRIPTION
    사용자별 사서함 이관 상태 확인
    OnPremise, Office365 Remote Session 접속 필요

.PARAMETER UserIds


.EXAMPLE
    PS C:\> .\Get-MailboxMigrationStatus -Identities @("aadctestuser09", "aadctestuser10") -StatusDetail
    Author: yaoh
    Last Edit: 2021-03-18
    Version 1.0 - 최초 작성  2021-03-18   
    
#>

[CmdletBinding()]
Param(

    [Parameter(mandatory=$true)]
    [string[]]
    $Identities,

    [Parameter()]
    [switch]
    $StatusDetail
   

)



$resultObjs = @()

foreach ($identity in $Identities) { 

    $resultObj =  New-Object PSObject -Property @{
        Success = $True
        Identity = $identity
    }

    try {

        $moveStatus = Get-O365MoveRequest -Identity $identity 

        $resultObj | Add-Member -MemberType NoteProperty -Name Status -Value $moveStatus.Status

        if($StatusDetail) {

            $moveStatusDetail = $moveStatus | Get-O365MoveRequestStatistics | Select-Object StatusDetail, PercentComplete
        
            $resultObj | Add-Member -MemberType NoteProperty -Name StatusDetail -Value $moveStatusDetail.StatusDetail
            $resultObj | Add-Member -MemberType NoteProperty -Name PercentComplete -Value $moveStatusDetail.PercentComplete
        }


    } catch {
        $resultObj.Success = $false
        $resultObj | Add-Member -MemberType NoteProperty -Name Error -Value $Error[0]
    }

    $resultObjs += $resultObj
}


return $resultObjs

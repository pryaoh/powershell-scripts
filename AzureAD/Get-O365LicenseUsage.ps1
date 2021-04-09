<# 
.SYNOPSIS
    Office365 라이선스 사용현황 조회
.DESCRIPTION
    라이선스 Sku 정보를 입력받아 사용량을 조회합니다.

.PARAMETER LicenseSkuPartNumbers
    라이선스 Sku 정보

.RETURN PSObject []
    PSObject 
      SkuPartNumber
      SkuId
      Total
      Used

.EXAMPLE
    PS C:\> .\Get-O365LicenseUsage.ps1 -LicenseSkuPartNumbers @("STANDARDPACK", "M365_F1_COMM", "OFFICESUBSCRIPTION")
.NOTES
    Author: pryaoh
    Last Edit: 2021-03-18
    Version 1.0 - 최초 작성  2021-03-18    
    
#>

[CmdletBinding()]
Param(

    [Parameter(mandatory=$false)]
    [AllowNull()]
    [string[]]
    $LicenseSkuPartNumbers = $null

)

$Global:subscribeLicenseList = $null # AzureAD 구독 라이선스 정보 리스트

$errorObj = $null

$resultObjs = @()


# Get Subscribe License Info
$tenantSkus = Get-AzureADSubscribedSku | Select-Object -Property SkuID,SkuPartNumber, ConsumedUnits,PrepaidUnits

if($LicenseSkuPartNumbers -ne $null -and $LicenseSkuPartNumbers.Count -gt 0) {
    $tenantSkus = $tenantSkus | WHERE-OBJECT  -Property SkuPartNumber -Value $LicenseSkuPartNumbers -IN
}
 
foreach($tenantSku in $tenantSkus) {

    $resultObj =  New-Object PSObject -Property @{
        SkuPartNumber = $tenantSku.SkuPartNumber
        SkuId = $tenantSku.SkuID
        Total = $tenantSku.PrepaidUnits.Enabled
        Used = $tenantSku.ConsumedUnits
    }

    $resultObjs += $resultObj
}

return $resultObjs

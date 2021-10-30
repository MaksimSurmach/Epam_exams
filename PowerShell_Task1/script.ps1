<#
    .Description
        Check if ip_address_1 and ip_address_2 belong to the same network or not.
    .NOTES
        -$ip_address_1  :   x.x.x.x format
        -$ip_address_2  :   x.x.x.x format
        -network_mask   :   x.x.x.x format or CIDR number
    .EXAMPLE
        script1.ps1 -ip_address_1 "192.168.0.1" -ip_address_2 "192.1.0.222" -network_mask "255.255.255.0"  
#>
param (
    [Parameter(Mandatory=$true)]
    [System.Net.IPAddress]$ip_address_1,    # input variable ip_address_1 must be IpAddr format x.x.x.x
    [Parameter(Mandatory=$true)]
    [System.Net.IPAddress]$ip_address_2,
    [Parameter(Mandatory=$true)]
    [string]$network_mask
)
process{
    [bool]$diffrentNetwork = $false;
    $RegExMask="\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"
    if ($network_mask -notmatch $RegExMask) {   #check if network mask like x.x.x.x or not
        
        if (([int]::Parse($network_mask) -lt 32)) {
            $network_mask = ("1" * $network_mask) + ("0" * (32 - $network_mask))       #generate net mask from CIDR
            [System.Net.IPAddress]$network_mask = [System.Net.IPAddress] ([Convert]::ToUInt64($network_mask, 2))
        }else{
            write-host "WRONG NETWORK MASK " $network_mask -ForegroundColor 'Red'
            exit
        }
    }else {
        [System.Net.IPAddress]$network_mask = [System.Net.IPAddress]::Parse($network_mask)  
    }
        
    Write-Host "First IPAddress = "$ip_address_1
    Write-Host "Second IPAddress= "$ip_address_2
    Write-Host "Network Maks    = "$network_mask
    $ip1 = $ip_address_1.GetAddressBytes()      # get array of octets
    $ip2 = $ip_address_2.GetAddressBytes()
    $mask = $network_mask.GetAddressBytes()
    for ($i = 0; $i -lt $ip1.Count; $i++) {     # make bitwise AND for ip_address_1 and ip_address_2 to MASK per octet
        if (($ip1[$i] -band $mask[$i]) -ne ($ip2[$i] -band $mask[$i])) {
            write-host $ip_address_1 "and" $ip_address_2 "NOT in same network" -ForegroundColor 'Red'
            $diffrentNetwork = $true;       # exit status 
            break;
        }
    }    
    if (!$diffrentNetwork) {    #test passed
        write-host $ip_address_1 "and" $ip_address_2 "in same network" -ForegroundColor 'Green'
    }   
}
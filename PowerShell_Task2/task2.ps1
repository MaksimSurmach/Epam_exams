<#
    .Description
        Format name and surname to Title case
        Generate email like "first letter from name" + "surname" + "location_id" + @abc.com
    .NOTES
        Imput CSV file to upgrade data
    .EXAMPLE
        script2.ps1 -FileInputPath Tasks_accounts.csv
#>
param (
    [Parameter(Mandatory=$true)]
    [string]$FileInputPath
)
process{
    $file = Get-Content -Path $FileInputPath | ConvertFrom-Csv  # Read file
    $TextInfo = (Get-Culture).TextInfo                          # Gets the current culture set in the operating system.
    foreach ($item in $file) {
        $item.email = ([string]::Concat( $item.name.Substring(0,1),
                        $item.name.Split(" ")[-1],
                        $item.location_id,
                        '@abc.com' )).ToLower()                 # generate new emails
        $item.name = $TextInfo.ToTitleCase($item.name)          # set first letter to uppercase
    }
    $output_name = "accounts_new.csv"
    $file | ConvertTo-Csv | Set-Content -Path .\$output_name    # generate new-file
    Write-Host "Generate "$output_name "file"
}

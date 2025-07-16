$inputFile = ""
$outputFile = ""

$machines = Import-Csv $inputFile
$count = 0
$results = foreach ($machine in $machines) {

    $address = $machine.'Port Address'

    $isIP = $address.StartsWith("1") # assumes IP addresses start with '1' (this is a simplification, adjust as needed)

    # DNS resolution
    try {
        $dnsResult = Resolve-DnsName -Name $address -ErrorAction Stop | Out-String
    } catch {
        $dnsResult = $_.Exception.Message
    }

    # ping test
    try {
        $pingResult = Test-Connection -ComputerName $address -Count 1 -Quiet -ErrorAction Stop
    } catch {
        $pingResult = $_.Exception.Message
    }

    [PSCustomObject]@{
        machine = $machine.'Machine Name' 
        Address = $address
        IsIPAddress = $isIP
        DNSResult = $dnsResult.Trim()
        PingSuccess = $pingResult
    }

    $count++
    Write-Host "$($address), $($count)"
}

$results | Export-Csv $outputFile -NoTypeInformation

function Test-Dotnetcore 
{
    <#
    .SYNOPSIS
    Returns $true if the remote machine successfully can run "dotnetcore --version". Otherwise returns $false 
    #>
    Param (
        [Parameter(Mandatory=$True,Position=0,ParameterSetName="Session based")]
        [SSH.SshSession]$SSHSession,
        [Parameter(Mandatory=$True,Position=0,ParameterSetName="Parameter based")]
        [string]$RemoteHost,
        [Parameter(Mandatory=$True,ParameterSetName="Parameter based")] 
        [string]$Username, 
        [Parameter(Mandatory=$True,ParameterSetName="Parameter based")]
        [string]$KeyFile
    )
    if($SSHSession -eq $null){
        $password = New-Object System.Security.SecureString
        $credentials = New-Object System.Management.Automation.PSCredential ($Username,$password)
        $SSHSession = New-SSHSession -ComputerName $RemoteHost -KeyFile $KeyFile -Credential $credentials -ConnectionTimeout 2000 -AcceptKey
    }

    if($SSHSession -eq $null -or $SSHSession.Connected -eq $false){
        return $false
    }
    $dotnetTestTask = $(Invoke-SSHCommand -SSHSession $SSHSession -Command ("dotnet --version") -TimeOut 10000)
    if($dotnetTestTask.ExitStatus -eq 0){
        return $true
    }
    return $false
}

function New-LocalSSHSession
{
    Param (
        [Parameter(Mandatory=$True)]
        [string]$RemoteHost,
        [Parameter(Mandatory=$True)] 
        [string]$Username,
        [Parameter(Mandatory=$True)] 
        [string]$KeyFile
    )
    $password = New-Object System.Security.SecureString
    $credentials = New-Object System.Management.Automation.PSCredential ($Username,$password)
    Write-Host ("Attempting to Deploy " + $ProjectName + " to " + $RemoteHost + "...") -NoNewline
    $sshSession = New-SSHSession -ComputerName $RemoteHost -KeyFile $KeyFile -Credential $credentials -ConnectionTimeout 2000 -AcceptKey
    return $sshSession
}

function New-LocalSFTPSession
{
    Param (
        [Parameter(Mandatory=$True)]
        [string]$RemoteHost,
        [Parameter(Mandatory=$True)] 
        [string]$Username,
        [Parameter(Mandatory=$True)] 
        [string]$KeyFile
    )
    $password = New-Object System.Security.SecureString
    $credentials = New-Object System.Management.Automation.PSCredential ($Username,$password)
    Write-Host ("Attempting to Deploy " + $ProjectName + " to " + $RemoteHost + "...") -NoNewline
    $sshSession = New-SFTPSession -ComputerName $RemoteHost -KeyFile $KeyFile -Credential $credentials -ConnectionTimeout 2000  -AcceptKey
    return $sshSession
}

function Install-Dotnetcore
{
    Param (
        [Parameter(Mandatory=$True,Position=0,ParameterSetName="Session based")]
        [SSH.SshSession]$SSHSession,
        [Parameter(Mandatory=$True,Position=0,ParameterSetName="Parameter based")]
        [string]$RemoteHost,
        [Parameter(Mandatory=$True,ParameterSetName="Parameter based")] 
        [string]$Username, 
        [Parameter(Mandatory=$True,ParameterSetName="Parameter based")]
        [string]$KeyFile
    )
    if($SSHSession -eq $null){
        $password = New-Object System.Security.SecureString
        $credentials = New-Object System.Management.Automation.PSCredential ($Username,$password)
        $SSHSession = New-SSHSession -ComputerName $RemoteHost -KeyFile $KeyFile -Credential $credentials -ConnectionTimeout 2000 -AcceptKey
    }

    Write-Host "Testing for dotnetcore..." -NoNewline
    if((Test-Dotnetcore -SSHSession $SSHSession) -eq $true){
        Write-Host "already has dotnetcore installed."
        Start-Sleep -Seconds 1
        return
    }
    Write-Host "not installed."

    $sdkUrls = @{
        "Debian 8" = "https://dotnetcli.blob.core.windows.net/dotnet/Sdk/rel-1.0.0/dotnet-dev-debian-x64.latest.tar.gz"; 
        "Ubuntu 16.04" = "https://dotnetcli.blob.core.windows.net/dotnet/Sdk/rel-1.0.0/dotnet-dev-ubuntu.16.04-x64.latest.tar.gz";
    }

    $osDetails = $(Invoke-SSHCommand -SSHSession $SSHSession -Command ("cat /etc/*-release") -TimeOut 10000);

    $sdkUrl = $null

    foreach ($line in $osDetails.Output) {
        if($line -like "*Ubuntu 16.04 LTS*"){
            $sdkUrl = $sdkUrls["Ubuntu 16.04"]
            Write-Host ("Detected OS as Ubuntu 16.04 LTS")
            break 
        }
        if($line -like "*Debian GNU/Linux 8*"){
            $sdkUrl = $sdkUrls["Debian 8"]
            Write-Host ("Detected OS as Debian 8")
            break 
        }
    }

    if($sdkUrl -eq $null){
        Write-Host "Could not detect valid OS version"
        return
    }

    Write-Host "Getting dependencies(This can take a while)..." -NoNewline
    $task = $(Invoke-SSHCommand -SSHSession $SSHSession -Command ("apt-get update") -TimeOut 120000)
    $task = $(Invoke-SSHCommand -SSHSession $SSHSession -Command ("apt-get --assume-yes install curl libunwind8 gettext") -TimeOut 120000)
    Write-Host "Done"

    Write-Host "Downloading SDK..." -NoNewline
    $task = $(Invoke-SSHCommand -SSHSession $SSHSession -Command ("curl -L -o dotnet.tar.gz " + $sdkUrl) -TimeOut 60000)
    Write-Host "Done."
    $task = $(Invoke-SSHCommand -SSHSession $SSHSession -Command ("mkdir -p /opt/dotnet && sudo tar zxf dotnet.tar.gz -C /opt/dotnet") -TimeOut 10000)
    $task = $(Invoke-SSHCommand -SSHSession $SSHSession -Command ("ln -s /opt/dotnet/dotnet /usr/local/bin") -TimeOut 10000)
    

    Write-Host "Testing for dotnetcore install(Might take a while pulling initial nuget cache)..." -NoNewline
    $testResult = (Test-Dotnetcore -SSHSession $SSHSession)
    Write-Host "Done"
    if($testResult){
        Write-Host -ForegroundColor Green "Success."
    }
    else{
        Write-Host -ForegroundColor Red "Failed."
    }
    $SSHSession.Disconnect();
    Start-Sleep -Seconds 1
}

Export-ModuleMember -function Test-Dotnetcore
Export-ModuleMember -function Install-Dotnetcore
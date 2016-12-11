# Dotnetcore-Remote-Install

Simple Powershell module for remote checking and installing the latest dotnetcore against linux machines

__Requires Posh-SSH Module__

Supported OS
* Debian GNU/Linux 8
* Ubuntu 16.04 LTS

Should be fairly simple to add more distributions if needed

## Usage

### Test-Dotnetcore

Returns $true if the remote machine successfully can run "dotnetcore --version". Otherwise returns $false
    
#### SYNTAX
* Test-Dotnetcore [-SSHSession] \<SshSession\>
* Test-Dotnetcore [-RemoteHost] \<String\> -Username \<String\> -KeyFile \<String\>

### Install-Dotnetcore

Outputs information regarding state of installation

#### SYNTAX
* Install-Dotnetcore [-SSHSession] \<SshSession\>
* Install-Dotnetcore [-RemoteHost] \<string\> -Username \<string\> -KeyFile \<string\>


## Examples
```
$remoteHost = "my-sick-nasty-linux-box.io"
$keyfile = "X:\dontlookinhere\private.rsa"

if((Test-Dotnetcore -RemoteHost $remoteHost -Username "root" -KeyFile $keyfile) -eq $false){
    Install-Dotnetcore -RemoteHost $remoteHost -Username "root" -KeyFile $keyfile
}
```
#### Output
```
Testing for dotnetcore...not installed.
Detected OS as Ubuntu 16.04 LTS
Getting dependencies(This can take a while)...Done
Downloading SDK...Done.
Testing for dotnetcore install(Might take a while pulling initial nuget cache)...Done
Success.
``` 
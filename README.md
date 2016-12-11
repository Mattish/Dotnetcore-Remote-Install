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

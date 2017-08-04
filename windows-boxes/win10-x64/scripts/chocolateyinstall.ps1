# chocolatey install script for Docker for Windows.
# source : https://chocolatey.org/packages/docker-for-windows/1.12.1

$ErrorActionPreference = 'Stop';

$packageName= 'docker-for-windows'
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url        = 'https://download.docker.com/win/stable/InstallDocker.msi'

$packageArgs = @{
  packageName   = $packageName
  unzipLocation = $toolsDir
  fileType      = 'MSI'
  url           = $url
  url64bit      = $url64

  softwareName  = 'docker*'

  checksum      = '89b9f231f292e8db433d3726fc92834a12eaa3f4aa474ace6352a13e486acb52'
  checksumType  = 'sha256'

  silentArgs    = "/qn /norestart /l*v `"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).MsiInstall.log`""
  validExitCodes= @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs

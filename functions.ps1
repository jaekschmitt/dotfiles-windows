# Basic commands
function which($name) { Get-Command $name -ErrorAction SilentlyContinue | Select-Object Definition }
function touch($file) { "" | Out-File $file -Encoding ASCII }

# Common Editing needs
function Edit-Hosts { Invoke-Expression "sudo $(if($env:EDITOR -ne $null)  {$env:EDITOR } else { 'notepad' }) $env:windir\system32\drivers\etc\hosts" }
function Edit-Profile { Invoke-Expression "$(if($env:EDITOR -ne $null)  {$env:EDITOR } else { 'notepad' }) $profile" }

# Sudo
function sudo() {
    if ($args.Length -eq 1) {
        start-process $args[0] -verb "runAs"
    }
    if ($args.Length -gt 1) {
        start-process $args[0] -ArgumentList $args[1..$args.Length] -verb "runAs"
    }
}

# System Update - Update RubyGems, NPM, and their installed packages
function System-Update() {
    gem update --system
    gem update
    npm install npm -g
    npm update -g
}

# Reload the Shell
function Reload-Powershell {
    $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
    [System.Diagnostics.Process]::Start($newProcess);
    exit
}

# Empty the Recycle Bin on all drives
function Empty-RecycleBin {
    $RecBin = (New-Object -ComObject Shell.Application).Namespace(0xA)
    $RecBin.Items() | %{Remove-Item $_.Path -Recurse -Confirm:$false}
}


### File System functions
### ----------------------------
# Create a new directory and enter it
function CreateAndSet-Directory([String] $path) { New-Item $path -ItemType Directory -ErrorAction SilentlyContinue; Set-Location $path}

### Environment functions
### ----------------------------

# Reload the $env object from the registry
function Refresh-Environment {
    $locations = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
                 'HKCU:\Environment'

    $locations | ForEach-Object {
        $k = Get-Item $_
        $k.GetValueNames() | ForEach-Object {
            $name  = $_
            $value = $k.GetValue($_)
            Set-Item -Path Env:\$name -Value $value
        }
    }
}

# Set a permanent Environment variable, and reload it into $env
function Set-Environment([String] $variable, [String] $value) {
    [System.Environment]::SetEnvironmentVariable("$variable", "$value","User")
    Invoke-Expression "`$env:${variable} = `"$value`""
}

### Utilities
### ----------------------------

# Extract a .zip file
function Unzip-File {
    <#
    .SYNOPSIS
       Extracts the contents of a zip file.

    .DESCRIPTION
       Extracts the contents of a zip file specified via the -File parameter to the
    location specified via the -Destination parameter.

    .PARAMETER File
        The zip file to extract. This can be an absolute or relative path.

    .PARAMETER Destination
        The destination folder to extract the contents of the zip file to.

    .PARAMETER ForceCOM
        Switch parameter to force the use of COM for the extraction even if the .NET Framework 4.5 is present.

    .EXAMPLE
       Unzip-File -File archive.zip -Destination .\d

    .EXAMPLE
       'archive.zip' | Unzip-File

    .EXAMPLE
        Get-ChildItem -Path C:\zipfiles | ForEach-Object {$_.fullname | Unzip-File -Destination C:\databases}

    .INPUTS
       String

    .OUTPUTS
       None

    .NOTES
       Inspired by:  Mike F Robbins, @mikefrobbins

       This function first checks to see if the .NET Framework 4.5 is installed and uses it for the unzipping process, otherwise COM is used.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string]$File,

        [ValidateNotNullOrEmpty()]
        [string]$Destination = (Get-Location).Path
    )

    $filePath = Resolve-Path $File
    $destinationPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Destination)

    if (($PSVersionTable.PSVersion.Major -ge 3) -and
       ((Get-ItemProperty -Path "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Full" -ErrorAction SilentlyContinue).Version -like "4.5*" -or
       (Get-ItemProperty -Path "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Client" -ErrorAction SilentlyContinue).Version -like "4.5*")) {

        try {
            [System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null
            [System.IO.Compression.ZipFile]::ExtractToDirectory("$filePath", "$destinationPath")
        } catch {
            Write-Warning -Message "Unexpected Error. Error details: $_.Exception.Message"
        }
    } else {
        try {
            $shell = New-Object -ComObject Shell.Application
            $shell.Namespace($destinationPath).copyhere(($shell.NameSpace($filePath)).items())
        } catch {
            Write-Warning -Message "Unexpected Error. Error details: $_.Exception.Message"
        }
    }
}

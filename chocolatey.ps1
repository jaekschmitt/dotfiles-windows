if ((which cinst) -eq $null) {
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    choco feature enable -n=allowGlobalConfirmation
}

# Tools

cinst curl
cinst git.install
cinst msysgit
cinst poshgit
cinst putty
cinst wget
cinst wput
cinst nuget.commandline

# Runtimes

cinst nodejs.install
cinst ruby

# Editors

cinst vim
cinst sublimetext3

# Applications 

cinst googlechrome
cinst fiddler
cinst firefox
cinst virtualbox
cinst sourcetree
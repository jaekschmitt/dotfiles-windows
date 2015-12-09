# # Configure Git
if (Test-Path (Join-Path $env:LOCALAPPDATA "GitHub")) {
    Push-Location (Join-Path $env:LOCALAPPDATA "GitHub")
    . ".\shell.ps1"
    Push-Location $env:github_posh_git
    Import-Module .\posh-git
    Pop-Location

    function global:prompt {
        $realLASTEXITCODE = $LASTEXITCODE

        # Reset color, which can be messed up by Enable-GitColors
        $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor

        Write-Host($pwd.ProviderPath) -nonewline

        Write-VcsStatus

        $global:LASTEXITCODE = $realLASTEXITCODE
        return "> "
    }

    # Git credentials
    # Not in the repository, to prevent people from accidentally committing under my name
    Set-Environment "GIT_AUTHOR_NAME" "jaekschmitt","User"
    Set-Environment "GIT_COMMITTER_NAME" $env:GIT_AUTHOR_NAME
    
    Set-Environment "GIT_AUTHOR_EMAIL" "jaekschmitt@gmail.com"
    Set-Environment "GIT_COMMITTER_EMAIL" $env:GIT_AUTHOR_EMAIL
    
    git config --global user.name $env:GIT_AUTHOR_NAME    
    git config --global user.email $env:GIT_AUTHOR_EMAIL

    Enable-GitColors
    Start-SshAgent -Quiet
    Pop-Location
}
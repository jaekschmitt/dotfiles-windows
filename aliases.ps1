# Navigation

${function:~} = { Set-Location ~ }
${function:Set-ParentLocation} = { Set-Location .. }; Set-Alias ".." Set-ParentLocation

${function:dt} = { Set-Location ~\Desktop }
${function:docs} = { Set-Location ~\Documents }
${function:dl} = { Set-Location ~\Downloads }
${function:dev} = { Set-Location ~\Development }

# File Listings

if (Get-Command ls.exe -ErrorAction SilentlyContinue | Test-Path) {
	rm alias: ls
	${function:ls} = { ls.exe --color @args }
	${function:la} = { ls -Force @args }
	${function:lsd} = { ls -Directory -Force @args }
} else {
	${function:la} = { ls -Force @args }
	${function:lsd} = { ls -Directory -Force @args }
}


# Curl Alternatives

if (Get-Command curl.exe -ErrorAction SilentlyContinue | Test-Path) {
    rm alias:curl
    ${function:curl} = { curl.exe @args }
    ${function:gurl} = { curl --compressed @args }
} else {
    ${function:gurl} = { curl -TransferEncoding GZip }
}

# Directory Creation
Set-Alias mkd CreateAndSet-Directory

# Empty Trash
Set-Alias emptytrash Empty-RecycleBin

# Reload The Shell
Set-Alias reload Reload-Powershell
param (
    # Parameter help description
    [Parameter(Mandatory=$true)]
    [SecureString]$Password
)
$ErrorActionPreference = "Stop"

Install-Module -Name Posh-SSH -Scope CurrentUser

$user = "root"
$hostName = "142.93.197.195"
# $userAndHost = "${user}@${hostName}"
$targetDirectory = "/var/www/johnmanos.dev/html/"
# $secpasswd = ConvertTo-SecureString $Password -AsPlainText -Force
$Credentials = New-Object System.Management.Automation.PSCredential($user, $Password)
Try {
    New-SFTPSession -ComputerName $hostName -Credential $Credentials 
    # Confirm connection
    Get-SFTPSession 
} catch {
    Write-Host -fore Red $error
    Write-Host -fore Red "`r`nFailed!"
    exit
}


# Create a zip file with the contents of distrib
$file = "dist.zip"
Write-Host -fore Cyan "`r`nCompressing archive on host: ${file}"
Try {
    Compress-Archive -Path .\dist -DestinationPath dist.zip -Force
    Write-Host -fore Green "`r`nDone."
} catch {
    Write-Host -fore Red $error
    Write-Host -fore Red "`r`nFailed!"
    exit
}


# Delete remote file
Write-Host -fore Cyan "`r`nDeleting archive file from remote..."
Try {
    # ssh $userAndHost -Credential "cd ${targetDirectory}; rm -f dist.zip; exit"
    $Command = "cd $targetDirectory; rm -rf ./*"
    $SSHSessionID = New-SSHSession -ComputerName $hostName -Credential $Credentials #Connect Over SSH
    Get-SSHSession
    Write-Host -fore Cyan "`r`nSessionID is $($SSHSessionID.SessionId)"
    Invoke-SSHCommand -SessionId $SSHSessionID.SessionId -Command $Command # Invoke Command Over SSH
    Write-Host -fore Green "`r`nSuccessfully deleted archive file from remote."
} catch {
    Write-Host -fore Red $error
    Write-Host -fore Red "`r`nFailed!"
    exit
}


# Upload file
Write-Host -fore Cyan "`r`Uploading archive file to remote via sftp..."
Try {
    $SFTPSessionId = (Get-SFTPSession).SessionId 
    Set-SFTPItem -SessionId $SFTPSessionId -Path $file -Destination $targetDirectory
    Write-Host -fore Green "`r`Successfully uploaded archive file to remote."
} catch {
    Write-Host -fore Red $error
    Write-Host -fore Red "`r`nFailed!"
    exit
}

# $ftp = "ftp://${hostName}${targetDirectory}"

# $webclient = New-Object System.Net.WebClient
# #$uri = New-Object System.Uri($ftp)
# $webclient.Credentials = New-Object System.Net.NetworkCredential($user, $Password)

# Write-Host -fore Cyan "`r`nUploading ${file} to ${ftp}..."

# $webclient.UploadFile($ftp, $file)


# Decompress file
Write-Host -fore Cyan "`r`nDecompressing archive on a remote directory:"
Try {
    # ssh $userAndHost "cd ${targetDirectory}; unzip dist; mv dist/* dist/.* .; rm -rf dist dist.zip; exit"
    $Command = "cd $targetDirectory; unzip dist.zip; mv dist/* .; rm -rf dist dist.zip"
    Invoke-SSHCommand -SessionId $SSHSessionID.Sessionid -Command $Command -EnsureConnection # Invoke Command Over SSH
} catch {
    Write-Host -fore Red $error
    Write-Host -fore Red "`r`nFailed!"
    exit
}
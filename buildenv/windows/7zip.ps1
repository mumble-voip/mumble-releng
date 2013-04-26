. "./config.ps1"
. "./helpers.ps1"
. "./wget.ps1"

Function sevenZip_get {
<#
    .SYNOPSIS
        Ensures the 7-Zip is installed.
    .DESCRIPTION
        Ensures 7-Zip is present. If it is not
        the installer will be downloaded and run.
        On success 1 is returned.
#>
    if (sevenZip_present) {
        echo_green "Found existing 7-Zip version"
        return 1
    }

    if (!(sevenZip_installer_present)) {
        if (!(wget_download $sevenZip_url (download_path $sevenZip_file))) {
            return 0
        }
    }

    if (!(msi_install (download_path $sevenZip_file) ("/passive", "/norestart"))) {
        return 0
    }

    echo_green "Done, installed 7-Zip"

    return 1
}

Function sevenZip_require {
    if (!(sevenZip_present)) {
        throw "Requires 7-Zip"
    }
}

Function sevenZip_present {
    # Could check msi but this is ok too
    return (Test-Path $sevenZip_path -PathType Leaf)
}

Function sevenZip_installer_present {
    # Could check msi but this is ok too
    return (Test-Path (download_Path $sevenZip_file) -PathType Leaf)
}
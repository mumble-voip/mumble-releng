. "./config.ps1"
. "./helpers.ps1"
. "./wget.ps1"

Function winsdk_get {
<#
    .SYNOPSIS
        Ensures the windows sdk is installed.
    .DESCRIPTION
        Ensures windows sdk is present. If it is not
        the installer will be downloaded and run.
        On success 1 is returned.
#>
    if (winsdk_present) {
        echo_green "Found existing winsdk version"
        return 1
    }

    if (!(winsdk_iso_present)) {
        if (!(wget_download $winsdk_url (download_path $winsdk_iso))) {
            return 0
        }
    }


    # FIXME: Implement this
    echo_red "Not implemented"

    return 1
}



Function winsdk_present {
    return 1;
}

Function winsdk_debuggingtools_present
{
    if (is_installed $winsdk_debugtools) {
        return 1
    }
    return 0
}

Function winsdk_debuggingtools_get
{
    if (is_installed $winsdk_debugtools) {
        echo_green "Found existing $winsdk_debugtools"
        return 1
    }

    if (!(winsdk_iso_get)) {
        echo_red "Couldn't acquire Windows SDK ISO"
        return 0
    }

    $was_mounted = (winsdk_iso_drive)

    if (!(winsdk_iso_mount)) {
        echo_red "Failed to mount Windows SDK ISO"
        return 0
    }

    try {
        if (!(msi_install (winsdk_iso_path $winsdk_iso_debugtools) ("/passive", "/norestart"))) {
            return 0
        }
    }
    finally {
        if (!($was_mounted)) {
            winsdk_iso_unmount
        }
    }

    return 1
}

# Winsdk ISO functionality

Function winsdk_iso_path($what) {
    return (Join-Path $(winsdk_iso_drive) $what)
}

Function winsdk_iso_get {
    if (!(winsdk_iso_present)) {
        if (!(wget_download $winsdk_url (download_path $winsdk_iso))) {
            return 0
        }
    }
    return 1
}

Function winsdk_iso_present {
    return (Test-Path (download_path $winsdk_iso) -PathType Leaf)
}

Function winsdk_iso_drive {
    $letter = ((Get-DiskImage -ImagePath (download_path $winsdk_iso) | Get-Volume)).DriveLetter
    if (!($letter)) {
        return
    }

    return "$($letter):\"
}

Function winsdk_iso_mount {
    if (winsdk_iso_drive) {
        return winsdk_iso_drive
    }

    echo_neutral "Mounting '$winsdk_iso' ..."
    Mount-DiskImage -ImagePath (download_path $winsdk_iso) -StorageType ISO
    echo_green "Done, Mounted to $(winsdk_iso_drive)"

    return winsdk_iso_drive
}

Function winsdk_iso_unmount {
    if (!(winsdk_iso_drive)) {
        return
    }

    echo_neutral "Unmounting '$winsdk_iso'..."
    Dismount-DiskImage -ImagePath (download_path $winsdk_iso)
    echo_green "Done"

    return
}
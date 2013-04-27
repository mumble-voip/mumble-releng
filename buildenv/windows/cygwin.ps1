. "./helpers.ps1"
. "./config.ps1"

$env:CYGWIN="nodosfilewarning"

Function cygwin_exe {
    return (download_path $cfg.cygwin.installer.exe)
}

Function cygwin_get() {
<#
    .SYNOPSIS
        Ensures cygwin setup is present.
    .DESCRIPTION
        Ensures cygwin setup is present. If it is not
        the installer will be downloaded. On success 1
        is returned.
#>
    if (cygwin_present) {
        echo_green "Found existing cygwin installer at " + cygwin_exe
    }
    else {
        if(!(download $cfg.cygwin.installer.url (cygwin_exe))) {
            return 0
        }
    }
    return 1
}

Function cygwin_present {
<#
    .SYNOPSIS
        Returns true if cygwin is present.
#>
    return (Test-Path (cygwin_exe) -PathType Leaf)
}

Function require_cygwin {
<#
    .SYNOPSIS
        Throws an exception if cygwin isn't present
#>
    if (!(cygwin_present)) {
        throw "Requires cygwin"
    }
}

Function cygwin_install($what) {
<#
    .SYNOPSIS
        Installs a list of given packets using cygwin.
    .EXAMPLE
        cygwin_install rsync
        cygwin_install ("rsync", "wget")
        if (cygwin_install rsync) { echo Worked }

    .NOTES
        Requires administrator priviledges and cygwin to be installed.
#>
    require_cygwin
    require_admin

    echo_neutral ("Installing " + ($what -join ',') + " using cygwin (Do not close the window)...")

    $app = Start-Process (cygwin_exe) ($cfg.cygwin.installer.param + ("-P", ($what -join ','))) -Wait -PassThru -RedirectStandardOutput cygwin-setup.log
    if ($app.ExitCode -ne 0) {
        echo_red "Failed, check cygwin-setup.log for more information"
        return 0
    }

    # Reports 0 if users aborts too. Could pass -WindowStyle Hidden to prevent that
    # but then there's no progress indication.
    echo_green ("Successfully installed: " + ($what -join ','))

    return 1
}

Function cygwin_path($binary) {
    return (Join-Path (Join-Path $cfg.cygwin.root "bin") $binary)
}

Function cygwin_has($what) {
    return (Test-Path (cygwin_path($what)) -PathType Leaf)
}
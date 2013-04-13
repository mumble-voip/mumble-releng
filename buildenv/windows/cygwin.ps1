. "./helpers.ps1"
. "./config.ps1"

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
        echo_green "Found existing $cygwin_file"
    }
    else {
        if(!(download $cygwin_url $cygwin_file)) {
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
    return (Test-Path $cygwin_file -PathType Leaf)
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

    $app = Start-Process "./$cygwin_file" ($cygwin_param + ("-P", ($what -join ','))) -Wait -PassThru -RedirectStandardOutput cygwin-log.txt
    if ($app.ExitCode -eq 0) {
        # Reports 0 if users aborts too. Could pass -WindowStyle Hidden to prevent that
        # but then there's no progress indication.
        echo_green ("Successfully installed: " + ($what -join ','))
        return 1
    }

    echo_red "Failed, check setup.log for more information"
    return 0
}

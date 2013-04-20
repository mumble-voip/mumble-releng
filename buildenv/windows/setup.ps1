. "./cygwin.ps1"
. "./python2.ps1"
. "./winsdk.ps1"

# In powershell cwd can differ from what you navigated to with cd
# kinda dangerous if your download directory is relative (e.g. ./)
[System.IO.Directory]::SetCurrentDirectory((Get-Location).toString())

Function echo_config {
    # Echo important parts of the config
    echo_neutral ("Download directory: '" + $download_dir + "' ('" + [System.IO.Path]::GetFullPath($download_dir) + "')")
}

Function check_symbolserver_deps {
    echo_neutral "Checking symbolserver dependencies..."

    get_installed_applications 1

    $ret = 1
    if (cygwin_present) { echo_green "[ok] cygwin" }
    else { echo_red "[missing] cygwin"; $ret = 0 }
    if (cygwin_has "rsync.exe") { echo_green "[ok] rsync" }
    else { echo_red "[missing] rsync"; $ret = 0 }
    if (cygwin_has "wget.exe") { echo_green "[ok] wget" }
    else { echo_red "[missing] wget"; $ret = 0 }
    if (python2_present) { echo_green "[ok] $(python2_version)" }
    else { echo_red "[missing] python2"; $ret = 0 }
    if (winsdk_debuggingtools_present) { echo_green "[ok] $winsdk_debugtools" }
    else { echo_red "[missing] $winsdk_debuggtools"; $ret = 0 }

    return $ret
}

Function install_symbolserver_deps {
    #
    # Cygwin based dependencies
    #
    $cygwin_to_install = $null

    if (!(cygwin_has "rsync.exe")) {
        $cygwin_to_install += ,("rsync")
    }

    if (!(cygwin_has "wget.exe")) {
        $cygwin_to_install += ,("wget")
    }

    if ($cygwin_to_install) {
        if (!(cygwin_present)) {
            if (!(cygwin_get)) {
                echo_red "Failed to install cygwin"
                return 0
            }
        }

        if(!(cygwin_install $cygwin_to_install)) {
            echo_red ("Failed to install one or more of " + ($cygwin_to_install -join ','))
            return 0
        }
    }

    if (!(python2_present)) {
        if (!(python2_get)) {
            echo_red "Failed to install python2"
            return 0
        }
    }

    #
    # Windows SDK based dependencies
    #
    if (!(winsdk_debuggingtools_present)) {
        if (!(winsdk_debuggingtools_get)) {
            echo_red "Failed to install $winsdk_debugtools"
            return 0
        }
    }

    return 1
}
Function setup_symbolserver() {
    trap {
        echo_red ("Error, " + $_.toString())
        echo_ref $_
        return 1
    }

    echo_config
    if (!(check_symbolserver_deps)) {
        echo_neutral "Will now install missing dependencies"

        if((!(install_symbolserver_deps)) -or (!(check_symbolserver_deps))) {
            echo_red "Failed to install one or more dependencies"
            return 1
        }
    }


    echo_neutral ("Creating symbol store in '" + $symstore_path + "'...")
    md $symstore_path -ErrorAction Stop
    echo_green "Ok"


    echo_green "Symbol server ready"
    return 0
}

Function setup {
    # Make sure the download directory exists
    md $download_dir -ErrorAction Ignore
    if(!(Test-Path $download_dir -PathType Container)) {
        echo_red "Failed to create download directory: $download_dir"
        return 1
    }

    setup_symbolserver
}

# For now call it here directly so bootstrapping works
setup

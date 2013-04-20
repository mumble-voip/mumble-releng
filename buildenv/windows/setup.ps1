. "./cygwin.ps1"
. "./python2.ps1"

# In powershell cwd can differ from what you navigated to with cd
# kinda dangerous if your download directory is relative (e.g. ./)
[System.IO.Directory]::SetCurrentDirectory((Get-Location).toString())

Function echo_config {
    # Echo important parts of the config
    echo_neutral ("Download directory: '" + $download_dir + "' ('" + [System.IO.Path]::GetFullPath($download_dir) + "')")
}

Function check_deps {
    echo_neutral "Checking symbolserver dependencies..."
    $ret = 1
    if (cygwin_present) { echo_green "[ok] cygwin" }
    else { echo_red "[missing] cygwin"; $ret = 0 }
    if (cygwin_has "rsync.exe") { echo_green "[ok] rsync" }
    else { echo_red "[missing] rsync"; $ret = 0 }
    if (cygwin_has "wget.exe") { echo_green "[ok] wget" }
    else { echo_red "[missing] wget"; $ret = 0 }
    if (python2_present) { echo_green ("[ok] " + (python2_version)) }
    else { echo_red "[missing] python2"; $ret = 0 }
    return $ret
}

Function install_deps {
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
        if(!(python2_get)) {
            echo_red "Failed to install python2"
            return 0
        }
    }

    return 1
}
Function setup_symbolserver() {
    echo_config
    if (!(check_deps)) {
        echo_neutral "Will now install missing dependencies"

        if((!(install_deps)) -or (!(check_deps))) {
            echo_red "Failed to install one or more dependencies"
            return 1
        }
    }


    return 0
}

# For now call it here directly so bootstrapping works
setup_symbolserver

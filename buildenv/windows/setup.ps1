. "./config.ps1"
. "./cygwin.ps1"
. "./python2.ps1"
. "./winsdk.ps1"
. "./7zip.ps1"

# In powershell cwd can differ from what you navigated to with cd
# kinda dangerous if your download directory is relative (e.g. ./)
[System.IO.Directory]::SetCurrentDirectory((Get-Location).toString())

Function echo_config {
    # Echo important parts of the config
    echo_neutral "Download directory: '$($cfg.setup.download_dir)' ('$([System.IO.Path]::GetFullPath($cfg.setup.download_dir))')"
    echo_neutral "Log directory: '$($cfg.setup.logging_dir)' ('$([System.IO.Path]::GetFullPath($cfg.setup.logging_dir))')"
}

Function check_symbolserver_deps {
    get_installed_applications 1 > $null

    echo_neutral "Checking symbolserver dependencies..."

    $ret = 1
    if (cygwin_present) { echo_green "[ok] cygwin" }
    else { echo_red "[missing] cygwin"; $ret = 0 }
    if (cygwin_has "rsync.exe") { echo_green "[ok] rsync" }
    else { echo_red "[missing] rsync"; $ret = 0 }
    if (cygwin_has "wget.exe") { echo_green "[ok] wget" }
    else { echo_red "[missing] wget"; $ret = 0 }
    if (cygwin_has "ssh.exe") { echo_green "[ok] ssh" }
    else { echo_red "[missing] ssh"; $ret = 0 }
    if (python2_present) { echo_green "[ok] $(python2_version)" }
    else { echo_red "[missing] python2"; $ret = 0 }
    if (winsdk_debuggingtools_present) { echo_green "[ok] $($cfg.winsdk.components.debugtools.name)" }
    else { echo_red "[missing] $($cfg.winsdk.components.debugtools.name)"; $ret = 0 }
    if (sevenZip_present) { echo_green "[ok] 7-Zip" }
    else { echo_red "[missing] 7-Zip"; $ret = 0 }

    return $ret
}

Function install_symbolserver_deps {
    #
    # Cygwin based dependencies
    #
    $cygwin_to_install = $null

    if (!(cygwin_present)) {
        if (!(cygwin_get)) {
            echo_red "Failed to install cygwin"
            return 0
        }
    }

    if (!(cygwin_has "rsync.exe")) {
        $cygwin_to_install += ,("rsync")
    }

    if (!(cygwin_has "wget.exe")) {
        $cygwin_to_install += ,("wget")
    }

    if (!(cygwin_has "ssh.exe")) {
        $cygwin_to_install += ,("openssh")
    }

    if ($cygwin_to_install) {

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
            echo_red "Failed to install $($cfg.winsdk.components.debugtools.name)"
            return 0
        }
    }


    if (!(sevenZip_present)) {
        if (!(sevenZip_get)) {
            echo_red "Failed to install 7-Zip"
            return 0
        }
    }

    return 1
}
Function setup_symbolserver {
    trap {
        echo_red ("Error, " + $_.toString())
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

    echo_neutral ("Creating symbol store in '$($cfg.symstore.root)'...")
    md $cfg.symstore.root -ErrorAction Stop > $null
    & $cfg.symstore.exe add /f "invalidthingicanpass" /s $cfg.symstore.root /t "None" /c "This is a empty commit to initialize the store"
    echo_green "Ok"


    echo_green "Symbol server ready"
    return 0
}

Function setup {
    # Make sure the download directory exists
    md $cfg.setup.download_dir -ErrorAction Ignore > $null
    if(!(Test-Path $cfg.setup.download_dir -PathType Container)) {
        echo_red "Failed to create download directory: $($cfg.setup.download_dir)"
        return 1
    }

    # Make sure the logging directory exists
    md $cfg.setup.logging_dir -ErrorAction Ignore > $null
    if(!(Test-Path $cfg.setup.logging_dir -PathType Container)) {
        echo_red "Failed to create download directory: $($cfg.setup.logging_dir)"
        return 1
    }

    setup_symbolserver
}

# For now call it here directly so bootstrapping works
setup

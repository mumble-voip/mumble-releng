. "./config.ps1"
. "./helpers.ps1"
. "./wget.ps1"

Function python2_get {
<#
    .SYNOPSIS
        Ensures python2 is installed.
    .DESCRIPTION
        Ensures python2 is present. If it is not
        the installer will be downloaded and run.
        On success 1 is returned.
#>
    if (python2_present) {
        echo_green ("Found existing python2 version " + (python2_version))
        return 1;
    }

    if (!(python2_installer_present)) {
        if (!(wget_download $cfg.python2.installer.url (download_path $cfg.python2.installer.msi))) {
            return 0
        }
    }

    echo_neutral "Installing python2 using '$($cfg.python2.installer.msi)'"
    $app = Start-Process "msiexec.exe" ($cfg.python2.installer.param + ("/i", $cfg.python2.installer.msi, "/log", "python2-installer.log")) -Wait -PassThru -WorkingDirectory (download_path)
    $success_codes = (0, 3010) # 0=Success, 3010=Reboot required
    if ($success_codes -notcontains $app.ExitCode) {
        echo_red ("Failed (" + $app.ExitCode + "), check python2-installer.log for more information")
        return 0
    }
    echo_green ("Done, installed python2 version " + (python2_version))

    return 1
}

Function python2_require {
    if (!(python2_present)) {
        throw "Requires python2"
    }
}

Function python2_installer_present {
    return (Test-Path (download_path $cfg.python2.installer.msi) -PathType Leaf)
}

Function python2_present {
    return (Test-Path $cfg.python2.exe -PathType Leaf)
}

Function python2_version {
    python2_require

    return ((& $cfg.python2.exe ("--version") 2>&1).TargetObject)
}
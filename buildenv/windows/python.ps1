. "./config.ps1"
. "./helpers.ps1"
. "./wget.ps1"

Function python_get {
<#
    .SYNOPSIS
        Ensures python is installed.
    .DESCRIPTION
        Ensures python is present. If it is not
        the installer will be downloaded and run.
        On success 1 is returned.
#>
    if (python_present) {
        echo_green ("Found existing python version " + (python_version))
        return 1;
    }

    if (!(python_installer_present)) {
        if (!(wget_download $python_url (download_path $python_installer))) {
            return 0
        }
    }

    echo_neutral ("Installing python using " + $python_installer)
    $app = Start-Process "msiexec.exe" ($python_installer_param + ("/i", $python_installer, "/log", "python-installer.log")) -Wait -PassThru -WorkingDirectory (download_path)
    $success_codes = (0, 3010) # 0=Success, 3010=Reboot required
    if ($success_codes -notcontains $app.ExitCode) {
        echo_red ("Failed (" + $app.ExitCode + "), check python-installer.log for more information")
        return 0
    }
    echo_green ("Done, installed python version " + (python_version))

    return 1
}

Function python_require {
    if (!(python_present)) {
        throw "Requires python"
    }
}

Function python_installer_present {
    return (Test-Path (download_path $python_installer) -PathType Leaf)
}

Function python_present {
    return (Test-Path $python_path -PathType Leaf)
}

Function python_version {
    python_require

    return ((& $python_path ("--version") 2>&1).TargetObject)
}
Function download($from, $to) {
<#
    .SYNOPSIS
        Downloads a file to a given location.
    .EXAMPLE
        download("http://something/somefile.txt", "somelocaltargetfile.txt")
#>
    echo_neutral "Downloading from $from to $to ..."
    $wc = New-Object System.Net.WebClient
    try {
        $wc.downloadFile($from, $to)
    }
    catch {
        echo_red Failed
        echo_red $_.Exception.ToString()
        return 0
    }
   
    echo_green Done
    return 1
}

Function am_i_admin {
<#
    .SYNOPSIS
        Returns true if the program is running with administrator priviledges.
#>
    $identity=[System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal=new-object System.Security.Principal.WindowsPrincipal($identity)
    $admin=[System.Security.Principal.WindowsBuiltInRole]::Administrator

    return $principal.IsInRole($admin)
}

Function require_admin {
<#
    .SYNOPSIS
        Throws an exception if the program isn't running with administrator priviledges.
#>
    if(!(am_i_admin)) {
        throw "Requires admin priviledges"
    }
}

Function echo_neutral($what) {
<#
    .SYNOPSIS
        Echo in neutral color
#>
    write-host $what
}

Function echo_green($what) {
<#
    .SYNOPSIS
        Echo in green color
#>
    write-host -ForegroundColor Green $what
}

Function echo_red($what) {
<#
    .SYNOPSIS
        Echo in red color
#>
    write-host -ForegroundColor Red $what
}

Function download_path($what) {
    return (Join-Path $download_dir $what)
}

$script:installed_applications = $null

Function get_installed_applications($force_refresh) {
<#
    .SYNOPSIS
        Returns a list of windows installer installed applications
    .DESCRIPTION
        Returns the list of applications installed with windows
        installer on this system. As the query takes quite long
        the call internally caches its result. To enforce a refresh
        pass 1.
#>
    if ($script:installed_applications -and (!($force_refresh))) {
        return $script:installed_applications
    }

    echo_neutral "Getting list of installed applications..."
    $script:installed_applications = @(Get-WmiObject -Class Win32_Product)
    echo_green ("Done (found $($script:installed_applications.Count))")

    return $script:installed_applications
}

Function is_installed($name) {
<#
    .SYNOPSIS
        Returns the application entry if installed
#>
     return (get_installed_applications | where { $_.Name -eq $name } )
}

Function msi_install($installer_path, $params, $success_codes = (,0)) {
<#
    .SYNOPSIS
        Installs a msi.
#>
    $file = Get-ChildItem $installer_path
    $installer = $file.Name
    $working_dir = $file.DirectoryName
    $log_path = (Join-Path $logging_dir ($installer + ".log"))

    echo_neutral "Installing $installer from $working_dir..."
    $app = Start-Process "msiexec.exe" ($params + ("/i", $installer, "/log", $log_path)) -Wait -PassThru -WorkingDirectory $working_dir
    if ($success_codes -notcontains $app.ExitCode) {
        echo_red ("Failed ($($app.ExitCode)), check $log_path for more information")
        return 0
    }
    echo_green "Done, installed $installer"
    return 1
}
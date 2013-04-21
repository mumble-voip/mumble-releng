# Configuration

$download_dir = "C:\dev\setup\"
$logging_dir = "C:\dev\setup\"

# Cygwin part
$cygwin_url = "http://www.cygwin.com/setup.exe"
$cygwin_file = "cygwin-setup.exe"
$cygwin_root = "C:\cygwin\"
$cygwin_packagedir = "C:\cygwin\packages"
$cygwin_mirror = "http://ftp.gwdg.de/pub/linux/sources.redhat.com/cygwin/"
$cygwin_param = ("-q", "-D", "-L", "-R", $cygwin_root, "-l", $cygwin_packagedir, "-s", $cygwin_mirror)

# Python 2
$python2_installer = "python-2.7.4.msi"
$python2_url = "http://www.python.org/ftp/python/2.7.4/python-2.7.4.msi"
$python2_installer_param = ("/qb!", "/norestart", "ALLUSERS=1")
$python2_path = "C:\Python27\python.exe"

# Windows SDK for Windows 7
$winsdk_iso = "GRMSDKX_EN_DVD.iso"
$winsdk_url = "http://download.microsoft.com/download/F/1/0/F10113F5-B750-4969-A255-274341AC6BCE/GRMSDKX_EN_DVD.iso"

$winsdk_iso_debugtools = "Setup\WinSDKDebuggingTools\dbg_x86.msi"
$winsdk_debugtools = "Debugging Tools for Windows (x86)"


# Symbol store
$symstore_exe = "C:\Program Files (x86)\Debugging Tools For Windows (x86)\symstore.exe"
$symstore_path = "C:\dev\symbolstore\"
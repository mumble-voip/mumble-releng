# Configuration

$download_dir = "."

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

# Symbol store
$symstore_exe = "C:\Program Files (x86)\Windows Kits\8.0\Debuggers\x86\symstore.exe"
$symstore_path = "C:\symbols\"
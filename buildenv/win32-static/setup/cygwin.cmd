:: Transitions the Mumble prep.bat cmd.exe-based
:: build environment to a Cywin environment in 
:: Cygwin's bash shell.

@echo off

for /f %%I in ('c:\cygwin\bin\cygpath %MUMBLE_PREFIX%') do set BOOTSTRAP_CYGWIN_MUMBLE_PREFIX=%%I
c:\cygwin\bin\bash.exe -c "source /etc/profile && source ${BOOTSTRAP_CYGWIN_MUMBLE_PREFIX}/env && cd ${MUMBLE_PREFIX} && bash"

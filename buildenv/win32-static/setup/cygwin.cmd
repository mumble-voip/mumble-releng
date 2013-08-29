:: Transitions the Mumble prep.bat cmd.exe-based
:: build environment to a Cywin environment in 
:: Cygwin's bash shell.

@echo off

c:\cygwin\bin\bash.exe -c "source ./env && bash"
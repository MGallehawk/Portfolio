@rem Teams room device setup, kajiggered by mathew gallehawk
@rem customised for teams rooms stations 2022-10-19
@echo off

@rem creates prompt for declaring the target pc
set /P RemotePC=RemotePC to set Teams room on user on: 


pause
@rem Operator station customisations
"%~dp0\psexec64.exe" \\%RemotePC% -h -accepteula net user TeamsRoom nuny4bizness! /ADD /FULLNAME:"TeamsRoom" /PASSWORDCHG:NO /EXPIRES:NEVER
"%~dp0\psexec64.exe" \\%RemotePC% -h -accepteula powershell -command "Set-LocalUser -Name """TeamsRoom""" -PasswordNeverExpires:$true -UserMayChangePassword:$false"
"%~dp0\psexec64.exe" \\%RemotePC% -h -accepteula CMD /C echo n |gpupdate /force /wait:-1
@rem Garry was here

@echo Press any key to reboot %RemotePC%
pause
shutdown /r /f /m \\%RemotePC% /t 0
goto :EOF


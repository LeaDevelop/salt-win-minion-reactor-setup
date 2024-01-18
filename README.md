# Saltstack Windows Reactor setup with Scheduler and Beacon

Setup is based on official [Salt user guide](https://docs.saltproject.io/salt/user-guide/en/latest/index.html) documentation.

> :warning: To make Scheduler, Beacon, Reactor trio working: salt-minion service must use Log On option as that user when you are setting anything specific for that user, if you don't adjust that then beacon will not work and consequently reactor as well.
 
Scheduler's job starts the powershell script that checks and logs current state of locale region format on the minion. Depending on the result it will send log file in designated directories `status / corrected / wrong`

# Scheduler 
Salt project official documentation: https://docs.saltproject.io/salt/user-guide/en/latest/topics/scheduler.html

# Beacons 
Salt project official documentation: https://docs.saltproject.io/salt/user-guide/en/latest/topics/beacons.html

# Reactor
Salt project official documentation: https://docs.saltproject.io/salt/user-guide/en/latest/topics/reactors.html

Locale region format is simple example on how to adjust configuration of minion with Windows OS, there is reg specific module that will help you getting that running via Salt. I'm using powershell script approach and using cmd.script function in the salt state file.

Useful links:
- https://docs.saltproject.io/en/latest/ref/modules/all/salt.modules.reg.html
- https://docs.saltproject.io/en/latest/ref/states/all/salt.states.cmd.html
-  https://learn.microsoft.com/en-us/windows/win32/intl/table-of-geographical-locations
-  https://learn.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-international-core-userlocale

# Verify all is running as expected
1. On salt master start `salt-run state.event pretty=true`
2. To test you can set scheduler and beacon interval to 20s both
3. On the minion set locale region format to a value that is not expected
4. Modify file in the Beacon watched directory
5Watch the state.event you'll see scheduler job first, following beacon and reactor

(!) Help yourself also with the minion log that is by default located in:
'C:\ProgramData\Salt Project\Salt\var\log\salt\minion'

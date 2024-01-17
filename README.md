# Saltstack Windows Reactor setup with Scheduler and Beacon

Setup is based on official [Salt user guide](https://docs.saltproject.io/salt/user-guide/en/latest/index.html) documentation.

> :warning: To make Scheduler, Beacon, Reactor trio working: salt-minion service must use Log On option as that user when you are setting anything specific for that user, if you don't adjust that then beacon will not work and consequently reactor as well.
 
Scheduler's job starts the powershell script that checks and logs current state of locale region format on the minion. Depending on the result it will send log file in designated directories `status / corrected / wrong`

# Scheduler 
Salt project official documentation: https://docs.saltproject.io/salt/user-guide/en/latest/topics/scheduler.html

# Beacons 
Salt project official documentation: https://docs.saltproject.io/salt/user-guide/en/latest/topics/beacons.html

# Salt project official documentation: https://docs.saltproject.io/salt/user-guide/en/latest/topics/reactors.html





`salt-run state.event pretty=true`
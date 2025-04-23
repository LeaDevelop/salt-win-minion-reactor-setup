# Salt - Windows minion reactor setup with scheduler and beacon

This is an example for Salt minions with MS Windows OS and configured scheduler, beacon and reactor.

The configuration will be checking whether region and regional have set expected valued. For example, I used dashboards that were based on log data, timestamps will differentiate based on region format, so I wanted to have additional check on provisioned machines.

I found two ways _the Salt way_ - use `reg` module (see example at bottom of common.sls) or *the Windows way*, using PowerShell script and `cmd.script` function in the salt state file. This document will show the example with PowerShell since `reg` module docs you'll find in official Salt docs.

The setup I used is based on official [Salt user guide](https://docs.saltproject.io/salt/user-guide/en/latest/index.html) documentation, I listed all relevant documentation in section below.

## Summary and dependencies

Scheduler's job starts the PowerShell script. The script checks and logs current state of locale region format on the minion. Depending on the result it will send log file in designated directories `status / corrected / wrong`

Scheduler triggers a check for current status and logs it's entry. Beacon (Watchdog) watched the directory and when there is file modified in designed directory, reactor will trigger a correction script and adjust region format to expected value.

If there is wrong value that will be noted in the .log file, which is stored to specific directory. That directory is monitored by the Watchdog. Reactor will follow with correction state file that has instructions to correct the value.

![scheduler-beacon-reactor_LeaDevelop.png](readme-assets/scheduler-beacon-reactor_LeaDevelop.png)

### Prerequisites

You have Salt master installed and configured, Windows minion is able to ping master server with success.

> ⚠ To make Scheduler, Beacon, Reactor trio working: salt-minion must use 'Log On' service property and fill in the credentials into This account option. If you don't set that, it will result beacon not working and consequently reactor not working as well.

## How to use
> ⚠ Ensure that you backed up your existing setup before you start with anything
>
> I made sure essentials for scheduler, beacon and reactor are shared in the repository, purpose of this repository is to help you understand where should they be configured. We all have structure different, the only file placement that matters is one also described in the image. Reactor config must be set on master server while beacon config must be set on the minion along with scheduler.


- On salt master start `salt-run state.event pretty=true`
- To test you can set scheduler and beacon interval to 20s both
- On the minion, set the locale region format to a value that is not expected

1. Reactor config is configured - `master/master.d/reactor.conf`
2. Beacon config is set and applied - `salt/dev/saltproject/windows/conf/minion.d/beacons.conf`
3. Schedule config set and applied - `salt/dev/saltproject/windows/conf/minion.d/_schedule.conf`
4. Master service and minion service were both restarted. ⚠ If you forget to restart it won't work.
5. Watch the `state.event` you'll see scheduler job first, following beacon and reactor

ℹ Help yourself also with the minion log that is by default located in:
`C:\ProgramData\Salt Project\Salt\var\log\salt\minion`

> Tested (21.04.2025) on minion, which was based on version: [3007.1](https://docs.saltproject.io/en/latest/topics/releases/3007.1.html)

## Salt project official documentation used for this setup
Scheduler:

- https://docs.saltproject.io/salt/user-guide/en/latest/topics/scheduler.html <br>
- https://docs.saltproject.io/en/latest/ref/states/all/salt.states.schedule.html<br>

Beacons:
- https://docs.saltproject.io/salt/user-guide/en/latest/topics/beacons.html <br>
- https://docs.saltproject.io/en/latest/ref/states/all/salt.states.beacon.html <br>

Reactor:
- https://docs.saltproject.io/salt/user-guide/en/latest/topics/reactors.html <br>
- https://docs.saltproject.io/en/latest/topics/reactor/<br>

## Other useful links:
- https://docs.saltproject.io/en/latest/ref/modules/all/salt.modules.reg.html
- https://docs.saltproject.io/en/latest/ref/states/all/salt.states.cmd.html
-  https://learn.microsoft.com/en-us/windows/win32/intl/table-of-geographical-locations
-  https://learn.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-international-core-userlocale

## Credits
Saltstack is available at: https://github.com/saltstack/salt / https://saltproject.io/ <br>
License: https://github.com/saltstack/salt?tab=Apache-2.0-1-ov-file <br>
Kudos to Salstack Windows workgroup for helping me out through this journey!<br>
PowerShell scripts are my own creation.

## Disclaimers
The use of scripts or shared content is solely at your own risk. I do not guarantee its accuracy, reliability, or suitability for your specific needs. No responsibility is taken for any damages or losses that may result from its use. It is recommended that you carefully review and test the content before implementation!<br><br>

# Install pip
ensure-pip-version:
  pip.installed:
    - name: pip == 25.0.1
# If the above not working, following will:
#chocolatey:
#  module.run:
#    - name: chocolatey.bootstrap
#python:
#  chocolatey.installed:
#    - name: python
#    - version: 3.13.3
#    - package_args: -y
#pip:
#  cmd.run:
#    - name: C:\Python313\python.exe -m pip install --upgrade pip==25.0.1

# Install Beacons config to a minion - required for Beacon
# https://docs.saltproject.io/salt/user-guide/en/latest/topics/beacons.html
salt-beacons-cfg:
  file.managed:
    - name: 'C:\ProgramData\Salt Project\Salt\conf\minion.d\beacons.conf'
    - source: salt://beacons/beacons.conf
    - require:
        - watchdog

# Salt minion service will restart, if watched file has changes
salt-minion-service:
  service.running:
    - name: salt-minion
    - enable: True
    - watch:
        - file: salt-beacons-cfg

# Scheduled job for logging locale region status
# https://docs.saltproject.io/en/latest/ref/states/all/salt.states.schedule.html
locale-region-status-scheduled-job:
  schedule.present:
    - function: state.sls
    - job_args:
        - scripts.logging.locale-region-status
    - job_kwargs:
        saltenv: dev
    - enabled: true
    - seconds: 86400
    - name: locale-region-status
    - jid_include: true
    - maxrunning: 1


# Salty way for first time apply expected values for locale region format into windows registry hive key
# Alternative way is scripts/*.ps1 solution
# (!) don't forget to set salt-minion service 'Log On' else some parts will not apply!
# https://learn.microsoft.com/en-us/windows/win32/intl/table-of-geographical-locations
# Country or region
# geo-name:
#  reg.present:
#    - name: HKEY_CURRENT_USER\Control Panel\International\Geo
#    - vname: Name
#    - vdata: US
#    - vtype: REG_SZ

#geo-nation:
#  reg.present:
#    - name: HKEY_CURRENT_USER\Control Panel\International\Geo
#    - vname: Nation
#    - vdata: 244
#    - vtype: REG_SZ

# https://learn.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-international-core-userlocale
# Regional format
# locale:
#  reg.present:
#    - name: HKEY_CURRENT_USER\Control Panel\International
#    - vname: Locale
#    - vdata: '00000409'
#    - vtype: REG_SZ

# locale-name:
#  reg.present:
#    - name: HKEY_CURRENT_USER\Control Panel\International
#    - vname: LocaleName
#    - vdata: en-US
#    - vtype: REG_SZ

# https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/default-time-zones?view=windows-10
# time-zone:
#  reg.present:
#    - name: HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\TimeZoneInformation
#    - vname: TimeZoneKeyName
#    - vdata: Central Europe Standard Time
#    - vtype: REG_SZ
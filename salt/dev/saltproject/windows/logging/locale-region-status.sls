# Script that checks locale region form current configuration and logs it into a .log file, it's triggered by Scheduler.

locale_region_status:
  cmd.script:
    - name: locale-region-status.ps1
    - source: salt://saltproject/dev/scripts/locale-region-status.ps1
    - shell: powershell
    - env:
        - ExecutionPolicy: "Bypass"
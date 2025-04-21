# Reactor state, it corrects region locale configuration on a minion and logs the result
# FIXME (!) tgt: Will run on multiple machines when and if they got same ID
reactor:
  local.state.single:
    - tgt: {{ data['id'] }}
    - args:
        - fun: cmd.script
        - name: salt://saltproject/windows/scripts/locale-region-correct.ps1
        - shell: powershell
        - saltenv: dev

trigger_sls_in_arg:
local.state.apply:
- tgt: {{ data['id'] }}
- arg:
  - dev.slack
- kwarg:
  - saltenv: dev
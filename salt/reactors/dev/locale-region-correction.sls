# Reactor state, it corrects region locale configuration on a minion and logs the result
{% if data['config'] == 'default' %}
locale_region_correction:
  local.state.single:
    - tgt: {{ data['id'] }}  # FIXME (!) Will run on multiple machines when and if they got same ID
    - args:
        - fun: cmd.script
        - name: salt://saltproject/windows/scripts/locale-region-correct.ps1
        - shell: powershell
        - saltenv: dev

 trigger_sls_in_arg:
  local.state.apply:
    - tgt: {{ data['id'] }}
    - arg:
      - dev.slack01
    - kwarg:
      - saltenv: dev

{% elif data['config'] == 'watchdog01' %}
locale_region_correction:
  local.state.single:
    - tgt: {{ data['id'] }}  # FIXME (!) Will run on multiple machines when and if they got same ID
    - args:
        - fun: cmd.script
        - name: salt://saltproject/windows/scripts/locale-region-correct.ps1
        - shell: powershell
        - saltenv: dev

trigger_sls_in_arg_watchdog01:
  local.state.apply:
    - tgt: {{ data['id'] }}
    - arg:
      - dev.slack02
    - kwarg:
      - saltenv: dev

{% endif %}

{% if data['config'] == 'default' %}
locale_region_correction:
  local.state.single:
    - tgt: {{ data['id'] }}
    - args:
      - fun: cmd.script
      - name: salt://scripts/locale-region-correction.ps1
      - shell: powershell
      - saltenv: dev

trigger_sls_in_arg:
  local.state.apply:
    - tgt: {{ data['id'] }}
    - arg:
      - dev.slack
    - kwarg:
      - saltenv: dev

{% elif data['config'] == 'watchdog01' %}
reactor-watchdog-01:
  local.state.single:
    - tgt: {{ data['id'] }}
    - args:
      - fun: cmd.script
      - name: salt://scripts/locale-region-correction.ps1
      - shell: powershell
      - saltenv: dev

trigger_sls_in_arg_watchdog01:
  local.state.apply:
    - tgt: {{ data['id'] }}
    - arg:
      - dev.slack
    - kwarg:
      - saltenv: dev
{% endif %}
# Reactor state, it corrects region locale configuration on a minion and logs the result

locale_region_correction:
  local.state.single:
    - tgt: {{ data['id'] }}  # FIXME (!) Will run on multiple machines when and if they got same ID
    - args:
        - fun: cmd.script
        - name: salt://saltproject/windows/scripts/locale-region-correct.ps1
        - shell: powershell
        - saltenv: base
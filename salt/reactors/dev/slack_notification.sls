slack-reactor:
  local.state.apply:
    - tgt: {{ data['id'] }}
    - arg:
      - dev.slack
    - kwarg:
      - saltenv: dev
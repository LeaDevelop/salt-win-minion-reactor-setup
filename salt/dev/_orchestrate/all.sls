# https://docs.saltproject.io/en/3007/faq.html#waiting-for-minions-to-come-back-online
# Following is simply an example

{% set current_env = 'dev' %}

common:
  salt.state:
    - tgt: {{ current_env }}
    - tgt_type: nodegroup
    - saltenv: {{ current_env }}
    - sls:
      - saltproject.windows.common

{% set expected_minions = salt.saltutil.runner('cache.mine', tgt=current_env,tgt_type='nodegroup').keys() %}
{% for minion_id in expected_minions %}
wait-after-common-for-{{ minion_id }}:
  loop.until_no_eval:
    - name: saltutil.runner
    - expected:
        - {{ minion_id }}
    - args:
        - manage.up
    - kwargs:
        tgt: {{ minion_id }}
    - period: 3
    - init_wait: 3
    - timeout: 300
{% endfor %}

restart:
  salt.state:
    - tgt: {{ current_env }}
    - tgt_type: nodegroup
    - saltenv: {{ current_env }}
    - sls:
      - saltproject.windows.restart-minion

{% set expected_minions = salt.saltutil.runner('cache.mine', tgt=current_env,tgt_type='nodegroup').keys() %}
{% for minion_id in expected_minions %}
wait-for-restart-{{ minion_id }}:
  loop.until_no_eval:
    - name: saltutil.runner
    - expected:
        - {{ minion_id }}
    - args:
        - manage.up
    - kwargs:
        tgt: {{ minion_id }}
    - period: 3
    - init_wait: 3
    # Overall timeout after initial wait
    - timeout: 300
{% endfor %}
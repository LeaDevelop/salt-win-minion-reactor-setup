# Restart minion

restart_after_setup:
  system.reboot:
    - message: "restarting after minion setup"
    - timeout: 5
    - in_seconds: True
    - only_on_pending_reboot: True
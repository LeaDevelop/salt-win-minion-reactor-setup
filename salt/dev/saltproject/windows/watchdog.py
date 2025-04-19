"""
Watch files and translate the changes into salt events.

.. versionadded:: 2019.2.0

.. versionchanged:: New in version - Added support for multiple directory configurations
:depends:   - watchdog Python module >= 0.8.3

"""

import collections
import logging

import salt.utils.beacons

try:
    # pylint: disable=no-name-in-module
    from watchdog.events import FileSystemEventHandler
    from watchdog.observers import Observer

    # pylint: enable=no-name-in-module

    HAS_WATCHDOG = True
except ImportError:
    HAS_WATCHDOG = False

    class FileSystemEventHandler:
        """A dummy class to make the import work"""

        def __init__(self):
            pass


__virtualname__ = "watchdog"

log = logging.getLogger(__name__)

DEFAULT_MASK = [
    "create",
    "delete",
    "modify",
    "move",
]


class Handler(FileSystemEventHandler):
    def __init__(self, queue, masks=None, config_name=None):
        super().__init__()
        self.masks = masks or DEFAULT_MASK
        self.queue = queue
        self.config_name = config_name

    def on_created(self, event):
        self._append_if_mask(event, "create")

    def on_modified(self, event):
        self._append_if_mask(event, "modify")

    def on_deleted(self, event):
        self._append_if_mask(event, "delete")

    def on_moved(self, event):
        self._append_if_mask(event, "move")

    def _append_if_mask(self, event, mask):
       # logging.debug(event)

        self._append_path_if_mask(event, mask)

    def _append_path_if_mask(self, event, mask):
        if mask in self.masks:
            # Add the config_name to identify which configuration triggered this event
            self.queue.append((event, self.config_name))


def __virtual__():
    if HAS_WATCHDOG:
        return __virtualname__
    err_msg = "watchdog library is missing."
    log.error("Unable to load %s beacon: %s", __virtualname__, err_msg)
    return False, err_msg


def _start_observers(config):
    """
    Start observers for all configurations
    """
    # Get configurations from config_list or use the main config as default
    if "config_list" in config:
        configs = config["config_list"]
    else:
        configs = [{"name": "default", "directories": config.get("directories", {})}]
        # Copy relevant settings to the default config
        for key in ["interval", "disable_during_state_run"]:
            if key in config:
                configs[0][key] = config[key]

    observers = {}
    queues = {}

    for cfg in configs:
        name = cfg.get("name", "default")

        observer_key = f"watchdog.observer.{name}"
        queue_key = f"watchdog.queue.{name}"

        # Skip if this observer is already running
        if observer_key in __context__:
            queues[name] = __context__[queue_key]
            continue

        # Create a new observer and queue
        queue = collections.deque()
        observer = Observer()

        directories = cfg.get("directories", {})

        for path in directories:
            path_params = directories[path]
            masks = path_params.get("mask", DEFAULT_MASK)
            event_handler = Handler(queue, masks, name)
            observer.schedule(event_handler, path)

        observer.start()

        __context__[observer_key] = observer
        __context__[queue_key] = queue
        queues[name] = queue

    return queues


class ValidationError(Exception):
    pass


def validate(config):
    """
    Validate the beacon configuration
    """

    try:
        _validate(config)
        return True, "Valid beacon configuration"
    except ValidationError as error:
        return False, str(error)


def _validate(config):
    if not isinstance(config, list):
        raise ValidationError("Configuration for watchdog beacon must be a list.")

    _config = {}
    for part in config:
        _config.update(part)

    # Validate the config_list structure
    if "config_list" in _config:
        if not isinstance(_config["config_list"], list):
            raise ValidationError("config_list must be a list.")

        for cfg in _config["config_list"]:
            if not isinstance(cfg, dict):
                raise ValidationError("Each item in config_list must be a dictionary.")

            if "directories" not in cfg:
                raise ValidationError("Each configuration must include directories.")

            if not isinstance(cfg["directories"], dict):
                raise ValidationError("Configuration directories must be a dictionary.")

            for path in cfg["directories"]:
                _validate_path(cfg["directories"][path])
    else:
        # Traditional validation
        if "directories" not in _config:
            raise ValidationError(
                "Configuration for watchdog beacon must include directories."
            )

        if not isinstance(_config["directories"], dict):
            raise ValidationError(
                "Configuration for watchdog beacon directories must be a dictionary."
            )

        for path in _config["directories"]:
            _validate_path(_config["directories"][path])


def _validate_path(path_config):
    if not isinstance(path_config, dict):
        raise ValidationError(
            "Configuration for watchdog beacon directory path must be a dictionary."
        )

    if "mask" in path_config:
        _validate_mask(path_config["mask"])


def _validate_mask(mask_config):
    valid_mask = [
        "create",
        "modify",
        "delete",
        "move",
    ]

    if not isinstance(mask_config, list):
        raise ValidationError("Configuration for watchdog beacon mask must be list.")

    if any(mask not in valid_mask for mask in mask_config):
        raise ValidationError("Configuration for watchdog beacon contains invalid mask")


def beacon(config):
    """
    Watch the configured directories

    Example Config with a single configuration:

    .. code-block:: yaml

        beacons:
          watchdog:
            - directories:
                /path/to/dir:
                  mask:
                    - create
                    - modify
                    - delete
                    - move
            - interval: 60
            - disable_during_state_run: True

    Example Config with multiple configurations:

    .. code-block:: yaml

        beacons:
          watchdog:
            - config_list:
                - name: default
                  directories:
                    /path/to/dir:
                      mask:
                        - modify
                  interval: 60
                - name: app1
                  directories:
                    /path/to/app1:
                      mask:
                        - create
                        - modify
                  interval: 10
            - disable_during_state_run: True

    Each configuration in config_list can have its own:
    - name: Unique identifier for this configuration (used in event data)
    - directories: List of directories to watch
    - interval: How often to check for changes (in seconds)

    Reactor configuration for the above example:

    .. code-block:: yaml

        reactor:
          # For all watchdog events
          - 'salt/beacon/*/watchdog/':
              - /srv/salt/reactors/watchdog_handler.sls

    In your reactor SLS file, you can filter based on the config field:

    .. code-block:: yaml

        # /srv/salt/reactors/watchdog_handler.sls
        {% if data['config'] == 'default' %}
        notify_default:
          local.cmd.run:
            - tgt: {{ data['id'] }}
            - arg:
              - echo "Default config changed: {{ data['path'] }}"
        {% elif data['config'] == 'app1' %}
        notify_app1:
          local.cmd.run:
            - tgt: {{ data['id'] }}
            - arg:
              - echo "App1 config changed: {{ data['path'] }}"
        {% endif %}

    The mask list can contain the following events (the default mask is create,
    modify delete, and move):

    * create  - File or directory is created in watched directory
    * modify  - The watched directory is modified
    * delete  - File or directory is deleted from watched directory
    * move    - File or directory is moved or renamed in the watched directory
    """

    config = salt.utils.beacons.list_to_dict(config)

    queues = _start_observers(config)

    ret = []
    for config_name, queue in queues.items():
        while queue:
            event, name = queue.popleft()
            # Build the event data
            event_data = {
                "path": event.src_path,
                "change": event.event_type,
                "config": name  # Include configuration name in the event data
            }
            # Add to return list - this is how Salt expects beacon events
            ret.append(event_data)

    return ret


def close(config):
    """
    Close all watchdog observers
    """
    config = salt.utils.beacons.list_to_dict(config)

    # Get configurations
    if "config_list" in config:
        configs = config["config_list"]
        config_names = [cfg.get("name", "default") for cfg in configs]
    else:
        config_names = ["default"]

    # Close each observer
    for name in config_names:
        observer_key = f"watchdog.observer.{name}"
        queue_key = f"watchdog.queue.{name}"

        observer = __context__.pop(observer_key, None)
        if observer:
            observer.stop()

        # Clean up the queue
        __context__.pop(queue_key, None)

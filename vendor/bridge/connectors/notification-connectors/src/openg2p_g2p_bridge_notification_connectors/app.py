# ruff: noqa: E402


from openg2p_fastapi_common.app import Initializer as BaseInitializer

from .config import Settings, load_impl
from .factory import NotificationFactory

_config = Settings.get_config()


class Initializer(BaseInitializer):
    def initialize(self, **kwargs):
        NotificationFactory()
        # Register the configured notifier (default: NovuNotifier; override via
        # G2P_BRIDGE_NOTIFICATION_CONNECTORS_IMPL).
        load_impl(_config.impl)()

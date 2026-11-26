# ruff: noqa: E402

from .config import Settings, load_impl

_config = Settings.get_config()

from openg2p_fastapi_common.app import Initializer as BaseInitializer

from .bank_connectors import BankConnectorFactory


class Initializer(BaseInitializer):
    def initialize(self, **kwargs):
        BankConnectorFactory()
        # Register each configured bank connector under its sponsor bank code so
        # the factory can dispatch by code. Add your bank via
        # G2P_BRIDGE_BANK_CONNECTORS_IMPLS.
        for bank_code, dotted_path in _config.impls.items():
            load_impl(dotted_path)(name=bank_code)

from openg2p_fastapi_common.service import BaseService

from ..bank_interface.bank_connector_interface import BankConnectorInterface
from ..config import Settings

_config = Settings.get_config()


class BankConnectorFactory(BaseService):
    def get_bank_connector(self, sponsor_bank_code: str) -> BankConnectorInterface:
        # Impls are registered under their sponsor bank code by the Initializer
        # (see Settings.impls); dispatch by code via the interface lookup.
        connector = BankConnectorInterface.get_component(name=sponsor_bank_code)
        if connector is None:
            raise NotImplementedError(
                f"Bank {sponsor_bank_code} is not supported. Configured banks: {list(_config.impls)}"
            )
        return connector

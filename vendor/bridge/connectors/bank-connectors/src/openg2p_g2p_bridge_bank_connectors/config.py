import importlib

from openg2p_fastapi_common.config import Settings as BaseSettings
from pydantic_settings import SettingsConfigDict


def load_impl(dotted_path: str):
    """Import 'pkg.module.ClassName' and return the class.

    Lets bank connectors be plugged in by config alone (no code change here).
    """
    module_path, _, class_name = dotted_path.rpartition(".")
    return getattr(importlib.import_module(module_path), class_name)


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_prefix="g2p_bridge_bank_connectors_", env_file=".env", extra="allow"
    )

    db_dbname: str = "openg2p_g2p_bridge_db"

    funds_available_check_url_example_bank: str = (
        "https://example-bank.dev.openg2p.org/api/example-bank/check_funds"
    )
    funds_block_url_example_bank: str = "https://example-bank.dev.openg2p.org/api/example-bank/block_funds"
    funds_disbursement_url_example_bank: str = (
        "https://example-bank.dev.openg2p.org/api/example-bank/initiate_payment"
    )
    bank_simulator_code: str = "EXAMPLE-BANK"

    # Map of sponsor bank code -> BankConnectorInterface impl (dotted path). The
    # factory dispatches per disbursement's sponsor bank code. To add your bank,
    # set G2P_BRIDGE_BANK_CONNECTORS_IMPLS, e.g.
    #   '{"MY-BANK": "my_pkg.MyBankConnector", "EXAMPLE-BANK": "...ExampleBankConnector"}'
    impls: dict[str, str] = {
        "EXAMPLE-BANK": ("openg2p_g2p_bridge_bank_connectors.bank_connectors.ExampleBankConnector")
    }

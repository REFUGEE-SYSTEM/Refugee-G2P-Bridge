import importlib

from openg2p_fastapi_common.config import Settings as BaseSettings
from pydantic_settings import SettingsConfigDict


def load_impl(dotted_path: str):
    """Import 'pkg.module.ClassName' and return the class.

    Lets the active connector implementation be selected by config alone, so an
    implementer can plug in their own without editing this package.
    """
    module_path, _, class_name = dotted_path.rpartition(".")
    return getattr(importlib.import_module(module_path), class_name)


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_prefix="g2p_bridge_mapper_connectors_", env_file=".env", extra="allow"
    )

    # Active mapper implementation (dotted path to a MapperInterface subclass).
    # Override with G2P_BRIDGE_MAPPER_CONNECTORS_IMPL to use your own.
    impl: str = "openg2p_g2p_bridge_mapper_connectors.implementations.SPARMapper"

    # SPAR Mapper configuration
    spar_mapper_url: str = "http://localhost:8080/mapper/resolve"
    spar_mapper_api_sign_enabled: bool = False
    spar_mapper_api_sign_crypto_helper_name: str = "spar_mapper_crypto"

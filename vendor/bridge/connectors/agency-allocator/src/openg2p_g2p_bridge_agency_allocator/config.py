import importlib

from openg2p_fastapi_common.config import Settings as BaseSettings
from pydantic_settings import SettingsConfigDict


def load_impl(dotted_path: str):
    """Import 'pkg.module.ClassName' and return the class (config-driven selection)."""
    module_path, _, class_name = dotted_path.rpartition(".")
    return getattr(importlib.import_module(module_path), class_name)


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_prefix="g2p_bridge_agency_allocator_", env_file=".env", extra="allow"
    )

    # Active agency-allocator implementation (dotted path to an AgencyAllocator
    # subclass). Override with G2P_BRIDGE_AGENCY_ALLOCATOR_IMPL.
    impl: str = "openg2p_g2p_bridge_agency_allocator.implementations.AgencyAllocatorRefImpl"

    db_dbname: str = "openg2p_g2p_bridge_db"

    # PBMS Database
    db_driver_pbms: str = "postgresql"
    db_username_pbms: str = "postgres"
    db_password_pbms: str = "postgres"
    db_hostname_pbms: str = "localhost"
    db_port_pbms: int = 5432
    db_dbname_pbms: str = "pbmsdb"

    # Add agency allocator specific config fields here

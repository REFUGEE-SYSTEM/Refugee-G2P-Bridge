import importlib

from openg2p_fastapi_common.config import Settings as BaseSettings
from pydantic_settings import SettingsConfigDict


def load_impl(dotted_path: str):
    """Import 'pkg.module.ClassName' and return the class (config-driven selection)."""
    module_path, _, class_name = dotted_path.rpartition(".")
    return getattr(importlib.import_module(module_path), class_name)


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_prefix="g2p_bridge_geo_resolver_", env_file=".env", extra="allow")

    db_dbname: str = "openg2p_g2p_bridge_db"

    # Map of (lower-cased) target registry -> GeoResolver impl (dotted path).
    # Add your registry resolver via G2P_BRIDGE_GEO_RESOLVER_IMPLS.
    impls: dict[str, str] = {
        "farmer": "openg2p_g2p_bridge_geo_resolver.implementations.FarmerGeoResolverImpl"
    }

    # Registry database connection settings
    db_driver_registry: str = "postgresql"
    db_username_registry: str = "postgres"
    db_password_registry: str = "postgres"
    db_hostname_registry: str = "localhost"
    db_port_registry: int = 5432
    db_dbname_registry: str = "registrydb"

from openg2p_fastapi_common.service import BaseService

from ..interface import GeoResolver


class GeoResolutionFactory(BaseService):
    def get_geo_resolver(self, target_registry: str) -> GeoResolver:
        # Impls are registered under their (lower-cased) target-registry key by
        # the Initializer (see Settings.impls). Returns None for an unconfigured
        # registry — unchanged behaviour.
        return GeoResolver.get_component(name=target_registry.lower())

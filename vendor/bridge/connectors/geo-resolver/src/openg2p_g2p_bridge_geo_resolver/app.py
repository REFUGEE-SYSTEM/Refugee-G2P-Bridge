# ruff: noqa: E402

from .config import Settings, load_impl

_config = Settings.get_config()

from openg2p_fastapi_common.app import Initializer as BaseInitializer

from .factory import GeoResolutionFactory


class Initializer(BaseInitializer):
    def initialize(self, **kwargs):
        GeoResolutionFactory()
        # Register each configured geo resolver under its target-registry key.
        for registry_key, dotted_path in _config.impls.items():
            load_impl(dotted_path)(name=registry_key)

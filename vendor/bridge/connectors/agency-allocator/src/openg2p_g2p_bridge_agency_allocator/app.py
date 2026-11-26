# ruff: noqa: E402


from openg2p_fastapi_common.app import Initializer as BaseInitializer

from .config import Settings, load_impl
from .factory import AgencyAllocatorFactory

_config = Settings.get_config()


class Initializer(BaseInitializer):
    def initialize(self, **kwargs):
        AgencyAllocatorFactory()
        # Register the configured agency allocator (default: AgencyAllocatorRefImpl).
        load_impl(_config.impl)()

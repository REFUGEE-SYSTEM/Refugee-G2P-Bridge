from openg2p_fastapi_common.service import BaseService

from ..interface import WarehouseAllocator


class WarehouseAllocatorFactory(BaseService):
    def get_warehouse_allocator(self) -> WarehouseAllocator:
        # Whichever WarehouseAllocator impl the Initializer registered (Settings.impl).
        return WarehouseAllocator.get_component()

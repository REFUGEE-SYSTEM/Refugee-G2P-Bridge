from openg2p_fastapi_common.service import BaseService

from ..interface import AgencyAllocator


class AgencyAllocatorFactory(BaseService):
    @staticmethod
    def get_agency_allocator() -> AgencyAllocator:
        # Whichever AgencyAllocator impl the Initializer registered (Settings.impl).
        return AgencyAllocator.get_component()

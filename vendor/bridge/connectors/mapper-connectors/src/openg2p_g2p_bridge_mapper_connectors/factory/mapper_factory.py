from openg2p_fastapi_common.service import BaseService

from ..interface.mapper_interface import MapperInterface


class MapperFactory(BaseService):
    @staticmethod
    def get_mapper() -> MapperInterface:
        # Returns whichever MapperInterface implementation the Initializer
        # registered (selected by Settings.impl) — isinstance-based lookup, so
        # no concrete impl is referenced here.
        return MapperInterface.get_component()

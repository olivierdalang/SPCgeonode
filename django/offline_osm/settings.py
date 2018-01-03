
from django.conf import settings

if not hasattr(settings,'OFFLINE_OSM_BBOX'):
    settings.OFFLINE_OSM_BBOX = [
        [176.8, -18.6], # BOTTOMLEFT
        [179.3, -17.1], # TOPRIGHT
    ]
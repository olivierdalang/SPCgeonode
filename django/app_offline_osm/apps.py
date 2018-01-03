from django.apps import AppConfig

class MyAppConfig(AppConfig):
    name = 'app_offline_osm'
    verbose_name = "Offline OSM"
    def ready(self):
        
        from . import settings
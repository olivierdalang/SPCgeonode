from django.apps import AppConfig
from django.core.management import call_command
from django.db.models.signals import post_migrate

class MyAppConfig(AppConfig):
    name = 'app_offline_osm'
    verbose_name = "Offline OSM"
    def ready(self):        
        # Import our custom settings
        from . import settings

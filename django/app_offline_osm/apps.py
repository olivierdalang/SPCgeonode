from django.apps import AppConfig
from django.core.management import call_command
from django.db.models.signals import post_migrate


def updateofflineosm_callback(sender, **kwargs):
    call_command("updateofflineosm", "--no_overwrite", "--no_fail")

class MyAppConfig(AppConfig):
    name = 'app_offline_osm'
    verbose_name = "Offline OSM"
    def ready(self):        
        # Import our custom settings
        from . import settings

        if settings.OFFLINE_OSM_AS_BASE_LAYER:
            post_migrate.connect(updateofflineosm_callback, sender=self)
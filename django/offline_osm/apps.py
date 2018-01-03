from django.apps import AppConfig

class MyAppConfig(AppConfig):
    name = 'offline_osm'
    verbose_name = "Offline OSM"
    def ready(self):
        print('TODO : run updateofflineosm and createbaselayers if needed')
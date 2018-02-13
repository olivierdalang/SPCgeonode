from django.conf.urls import patterns, url
from django.views.generic import TemplateView

from geonode.urls import *

urlpatterns = patterns('',
   url(r'^custom/$',
       TemplateView.as_view(template_name='custom_page.html'), name='custom_page'),
) + urlpatterns

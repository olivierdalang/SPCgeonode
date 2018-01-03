from django.contrib import admin
from .models import Log

class LogAdmin(admin.ModelAdmin):
    list_display = ['message','success','created_on']
    list_filter = ['success']

admin.site.register(Log, LogAdmin)
from django.db import models

class Log(models.Model):

    message = models.CharField(max_length=255)
    success = models.BooleanField()
    created_on = models.DateTimeField(auto_now_add=True)

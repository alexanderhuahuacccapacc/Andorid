from django.db import models

class Supplier(models.Model):
    name = models.CharField(max_length=100)
    document_number = models.CharField(max_length=20, unique=True)
    email = models.EmailField(blank=True, null=True)
    phone = models.CharField(max_length=20, blank=True, null=True)
    address = models.TextField(blank=True, null=True)

    def __str__(self):
        return self.name
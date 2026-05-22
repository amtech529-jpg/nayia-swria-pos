from django.db import models

class Supplier(models.Model):
    id = models.CharField(max_length=64, primary_key=True)
    name = models.CharField(max_length=255)
    email = models.EmailField(null=True, blank=True)
    phone = models.CharField(max_length=64, null=True, blank=True)
    address = models.TextField(null=True, blank=True)
    location = models.CharField(max_length=255, default='Default')
    purchase_total = models.DecimalField(max_digits=15, decimal_places=2, default=0.0)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    deleted = models.BooleanField(default=False)

    class Meta:
        db_table = 'suppliers'

    def __str__(self):
        return self.name

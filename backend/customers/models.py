from django.db import models

class Customer(models.Model):
    id = models.CharField(max_length=64, primary_key=True)
    name = models.CharField(max_length=255)
    father_name = models.CharField(max_length=255, null=True, blank=True)
    phone = models.CharField(max_length=64, null=True, blank=True)
    email = models.EmailField(null=True, blank=True)
    cnic = models.CharField(max_length=64, null=True, blank=True)
    address = models.TextField(null=True, blank=True)
    location = models.CharField(max_length=255, default='Default')
    area = models.CharField(max_length=255, default='None')
    balance = models.DecimalField(max_digits=15, decimal_places=2, default=0.0)
    image_url = models.CharField(max_length=500, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    deleted = models.BooleanField(default=False)

    class Meta:
        db_table = 'customers'

    def __str__(self):
        return self.name

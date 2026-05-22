from django.db import models


class Product(models.Model):
    id = models.CharField(max_length=64, primary_key=True)
    name = models.CharField(max_length=255)
    sku = models.CharField(max_length=64, null=True, blank=True)
    margin = models.DecimalField(max_digits=10, decimal_places=2, default=0.0)
    # Reference category by string label to avoid circular import across apps
    category_id = models.CharField(max_length=64, null=True, blank=True)
    category_name = models.CharField(max_length=255, null=True, blank=True)
    opening_stock = models.DecimalField(max_digits=15, decimal_places=2, default=0.0)
    cost = models.DecimalField(max_digits=15, decimal_places=2, default=0.0)
    price = models.DecimalField(max_digits=15, decimal_places=2, default=0.0)
    alert_qty = models.DecimalField(max_digits=10, decimal_places=2, default=1.0)
    location = models.CharField(max_length=255, default='Default')
    sale_unit = models.CharField(max_length=64, default='Sale Unit')
    extra_units = models.CharField(max_length=64, default='Extra Units')
    base_unit = models.CharField(max_length=64, default='Base Unit')
    purchase_unit = models.CharField(max_length=64, default='Purchase Unit')
    brand = models.CharField(max_length=128, null=True, blank=True)
    days_in_expiry = models.IntegerField(default=0)
    status = models.CharField(max_length=64, default='Active')
    notes = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    deleted = models.BooleanField(default=False)

    class Meta:
        db_table = 'products'

    def __str__(self):
        return self.name

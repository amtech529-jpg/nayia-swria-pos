from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.db import models
from django.utils import timezone


class UserManager(BaseUserManager):
    """Custom user manager for email-based authentication"""
    
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError('The Email field must be set')
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('agreed_to_terms', True)

        if extra_fields.get('is_superuser') is not True:
            raise ValueError('Superuser must have is_superuser=True.')

        return self.create_user(email, password, **extra_fields)


class User(AbstractBaseUser, PermissionsMixin):
    """Custom User model with email as username field"""
    
    # Roles
    ADMIN = 'ADMIN'
    MANAGER = 'MANAGER'
    SALES_AGENT = 'SALES_AGENT'
    ACCOUNTANT = 'ACCOUNTANT'
    STAFF = 'STAFF'
    
    ROLE_CHOICES = [
        (ADMIN, 'Admin'),
        (MANAGER, 'Manager'),
        (SALES_AGENT, 'Sales Agent'),
        (ACCOUNTANT, 'Accountant'),
        (STAFF, 'Staff'),
    ]

    id = models.AutoField(primary_key=True)
    full_name = models.CharField(max_length=255)
    email = models.EmailField(unique=True)
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default=ADMIN)
    agreed_to_terms = models.BooleanField(default=False)
    
    # Additional fields for Django admin and permissions
    is_active = models.BooleanField(default=True)
    date_joined = models.DateTimeField(default=timezone.now)
    last_login = models.DateTimeField(null=True, blank=True)

    @property
    def is_admin(self):
        return self.role == self.ADMIN or self.is_superuser

    @property
    def is_manager(self):
        return self.role == self.MANAGER

    @property
    def is_sales_agent(self):
        return self.role == self.SALES_AGENT

    @property
    def is_accountant(self):
        return self.role == self.ACCOUNTANT
    
    @property
    def is_staff(self):
        """Allow superusers to access admin without is_staff field"""
        return self.is_superuser
    
    objects = UserManager()
    
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['full_name']
    
    class Meta:
        db_table = 'user'
        verbose_name = 'User'
        verbose_name_plural = 'Users'
    
    def __str__(self):
        return self.email
    
    @property
    def get_full_name(self):
        return self.full_name
    
    @property
    def get_short_name(self):
        return self.full_name.split(' ')[0] if self.full_name else self.email


class Sale(models.Model):
    id = models.CharField(max_length=64, primary_key=True)
    invoice_no = models.CharField(max_length=64, unique=True)
    customer = models.ForeignKey('customers.Customer', on_delete=models.SET_NULL, null=True, blank=True, related_name='sales')
    location = models.CharField(max_length=255, default='Default')
    ref_no = models.CharField(max_length=255, null=True, blank=True)
    sale_date = models.DateTimeField(default=timezone.now)
    subtotal = models.DecimalField(max_digits=15, decimal_places=2, default=0.0)
    discount = models.DecimalField(max_digits=15, decimal_places=2, default=0.0)
    net_total = models.DecimalField(max_digits=15, decimal_places=2, default=0.0)
    paid_amount = models.DecimalField(max_digits=15, decimal_places=2, default=0.0)
    pending_amount = models.DecimalField(max_digits=15, decimal_places=2, default=0.0)
    payment_method = models.CharField(max_length=64, default='Cash')
    notes = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    deleted = models.BooleanField(default=False)

    class Meta:
        db_table = 'sales'

    def __str__(self):
        return self.invoice_no


class SaleItem(models.Model):
    id = models.AutoField(primary_key=True)
    sale = models.ForeignKey(Sale, on_delete=models.CASCADE, related_name='items')
    product_name = models.CharField(max_length=255)
    sku = models.CharField(max_length=64, null=True, blank=True)
    qty = models.IntegerField(default=1)
    price = models.DecimalField(max_digits=15, decimal_places=2, default=0.0)
    discount = models.DecimalField(max_digits=15, decimal_places=2, default=0.0)
    total_price = models.DecimalField(max_digits=15, decimal_places=2, default=0.0)

    class Meta:
        db_table = 'sale_items'


class Purchase(models.Model):
    id = models.CharField(max_length=64, primary_key=True)
    invoice_no = models.CharField(max_length=64, unique=True)
    supplier = models.ForeignKey('suppliers.Supplier', on_delete=models.SET_NULL, null=True, blank=True, related_name='purchases')
    location = models.CharField(max_length=255, default='Default')
    ref_no = models.CharField(max_length=255, null=True, blank=True)
    purchase_date = models.DateTimeField(default=timezone.now)
    subtotal = models.DecimalField(max_digits=15, decimal_places=2, default=0.0)
    discount = models.DecimalField(max_digits=15, decimal_places=2, default=0.0)
    net_total = models.DecimalField(max_digits=15, decimal_places=2, default=0.0)
    paid_amount = models.DecimalField(max_digits=15, decimal_places=2, default=0.0)
    pending_amount = models.DecimalField(max_digits=15, decimal_places=2, default=0.0)
    payment_method = models.CharField(max_length=64, default='Cash')
    notes = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    deleted = models.BooleanField(default=False)

    class Meta:
        db_table = 'purchases'

    def __str__(self):
        return self.invoice_no


class PurchaseItem(models.Model):
    id = models.AutoField(primary_key=True)
    purchase = models.ForeignKey(Purchase, on_delete=models.CASCADE, related_name='items')
    product_name = models.CharField(max_length=255)
    sku = models.CharField(max_length=64, null=True, blank=True)
    qty = models.IntegerField(default=1)
    price = models.DecimalField(max_digits=15, decimal_places=2, default=0.0)
    discount = models.DecimalField(max_digits=15, decimal_places=2, default=0.0)
    total_price = models.DecimalField(max_digits=15, decimal_places=2, default=0.0)

    class Meta:
        db_table = 'purchase_items'


class Unit(models.Model):
    id = models.CharField(max_length=64, primary_key=True)
    name = models.CharField(max_length=100)
    short_name = models.CharField(max_length=50)
    base_unit = models.CharField(max_length=100, null=True, blank=True)
    base_unit_multiplier = models.DecimalField(max_digits=10, decimal_places=2, default=1.0)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    deleted = models.BooleanField(default=False)

    class Meta:
        db_table = 'units'

    def __str__(self):
        return self.name


class SaleReturn(models.Model):
    id = models.CharField(max_length=64, primary_key=True)
    sale = models.ForeignKey(Sale, on_delete=models.SET_NULL, null=True, related_name='returns')
    return_no = models.CharField(max_length=64, unique=True)
    return_date = models.DateTimeField(default=timezone.now)
    total_amount = models.DecimalField(max_digits=15, decimal_places=2, default=0.0)
    reason = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    deleted = models.BooleanField(default=False)

    class Meta:
        db_table = 'sale_returns'

class SaleReturnItem(models.Model):
    id = models.AutoField(primary_key=True)
    sale_return = models.ForeignKey(SaleReturn, on_delete=models.CASCADE, related_name='items')
    product_name = models.CharField(max_length=255)
    qty = models.IntegerField(default=1)
    price = models.DecimalField(max_digits=15, decimal_places=2, default=0.0)
    total_price = models.DecimalField(max_digits=15, decimal_places=2, default=0.0)

    class Meta:
        db_table = 'sale_return_items'


class PurchaseReturn(models.Model):
    id = models.CharField(max_length=64, primary_key=True)
    purchase = models.ForeignKey(Purchase, on_delete=models.SET_NULL, null=True, related_name='returns')
    return_no = models.CharField(max_length=64, unique=True)
    return_date = models.DateTimeField(default=timezone.now)
    total_amount = models.DecimalField(max_digits=15, decimal_places=2, default=0.0)
    reason = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    deleted = models.BooleanField(default=False)

    class Meta:
        db_table = 'purchase_returns'

class PurchaseReturnItem(models.Model):
    id = models.AutoField(primary_key=True)
    purchase_return = models.ForeignKey(PurchaseReturn, on_delete=models.CASCADE, related_name='items')
    product_name = models.CharField(max_length=255)
    qty = models.IntegerField(default=1)
    price = models.DecimalField(max_digits=15, decimal_places=2, default=0.0)
    total_price = models.DecimalField(max_digits=15, decimal_places=2, default=0.0)

    class Meta:
        db_table = 'purchase_return_items'


class AreaManager(models.Model):
    id = models.CharField(max_length=64, primary_key=True)
    name = models.CharField(max_length=255)
    phone = models.CharField(max_length=255, null=True, blank=True)
    email = models.CharField(max_length=255, null=True, blank=True)
    address = models.TextField(null=True, blank=True)
    area = models.CharField(max_length=255, default='None')
    balance = models.DecimalField(max_digits=15, decimal_places=2, default=0.0)
    status = models.CharField(max_length=50, default='Active')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    deleted = models.BooleanField(default=False)

    class Meta:
        db_table = 'area_managers'

    def __str__(self):
        return self.name
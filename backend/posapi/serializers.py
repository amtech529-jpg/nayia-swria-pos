from rest_framework import serializers
from django.contrib.auth import authenticate
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError
from .models import User


class UserRegistrationSerializer(serializers.ModelSerializer):
    """Serializer for user registration"""
    
    password = serializers.CharField(
        write_only=True,
        min_length=8,
        style={'input_type': 'password'}
    )
    password_confirm = serializers.CharField(
        write_only=True,
        style={'input_type': 'password'}
    )
    
    class Meta:
        model = User
        fields = ('id', 'full_name', 'email', 'role', 'password', 'password_confirm', 'agreed_to_terms')
        extra_kwargs = {
            'password': {'write_only': True},
            'id': {'read_only': True}
        }
    
    def validate_email(self, value):
        """Validate email uniqueness"""
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError("User with this email already exists.")
        return value
    
    def validate_agreed_to_terms(self, value):
        """Validate that user agreed to terms"""
        if not value:
            raise serializers.ValidationError("You must agree to the terms and conditions.")
        return value
    
    def validate(self, attrs):
        """Validate password confirmation and strength"""
        password = attrs.get('password')
        password_confirm = attrs.get('password_confirm')
        
        if password != password_confirm:
            raise serializers.ValidationError({
                'password_confirm': 'Password confirmation does not match.'
            })
        
        # Validate password strength using Django's validators
        try:
            validate_password(password)
        except ValidationError as e:
            raise serializers.ValidationError({'password': e.messages})
        
        return attrs
    
    def create(self, validated_data):
        """Create user with encrypted password"""
        validated_data.pop('password_confirm')
        password = validated_data.pop('password')
        
        user = User.objects.create_user(
            password=password,
            **validated_data
        )
        return user


class UserLoginSerializer(serializers.Serializer):
    """Serializer for user login"""
    
    email = serializers.EmailField()
    password = serializers.CharField(
        style={'input_type': 'password'},
        trim_whitespace=False
    )
    
    def validate(self, attrs):
        """Validate user credentials"""
        email = attrs.get('email')
        password = attrs.get('password')
        
        if email and password:
            user = authenticate(
                request=self.context.get('request'),
                username=email,
                password=password
            )
            
            if not user:
                raise serializers.ValidationError(
                    'Invalid email or password.',
                    code='authorization'
                )
            
            if not user.is_active:
                raise serializers.ValidationError(
                    'User account is disabled.',
                    code='authorization'
                )
            
            attrs['user'] = user
            return attrs
        else:
            raise serializers.ValidationError(
                'Must include email and password.',
                code='authorization'
            )


class UserSerializer(serializers.ModelSerializer):
    """Serializer for user profile"""
    
    class Meta:
        model = User
        fields = ('id', 'full_name', 'email', 'role', 'date_joined', 'last_login')
        read_only_fields = ('id', 'date_joined', 'last_login')


class ChangePasswordSerializer(serializers.Serializer):
    """Serializer for changing password"""
    
    old_password = serializers.CharField(style={'input_type': 'password'})
    new_password = serializers.CharField(
        min_length=8,
        style={'input_type': 'password'}
    )
    new_password_confirm = serializers.CharField(style={'input_type': 'password'})
    
    def validate_old_password(self, value):
        """Validate old password"""
        user = self.context['request'].user
        if not user.check_password(value):
            raise serializers.ValidationError('Old password is incorrect.')
        return value
    
    def validate(self, attrs):
        """Validate new password confirmation"""
        new_password = attrs.get('new_password')
        new_password_confirm = attrs.get('new_password_confirm')
        
        if new_password != new_password_confirm:
            raise serializers.ValidationError({
                'new_password_confirm': 'New password confirmation does not match.'
            })
        
        # Validate password strength
        return attrs


from .models import Sale, SaleItem, Purchase, PurchaseItem

class SaleItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = SaleItem
        fields = '__all__'

class SaleSerializer(serializers.ModelSerializer):
    items = SaleItemSerializer(many=True, read_only=True)
    customer_name = serializers.ReadOnlyField(source='customer.name', default='Walk In Customer')

    class Meta:
        model = Sale
        fields = '__all__'

    def create(self, validated_data):
        # Allow nested creation of items from request data
        items_data = self.context.get('request').data.get('items', [])
        sale = Sale.objects.create(**validated_data)
        for item_data in items_data:
            # Prevent nested parameter conflicts
            item_data.pop('sale', None)
            SaleItem.objects.create(sale=sale, **item_data)
        return sale

    def update(self, instance, validated_data):
        # Update main Sale fields
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()

        # Update SaleItems: delete existing ones and recreate
        items_data = self.context.get('request').data.get('items', [])
        if items_data:
            instance.items.all().delete()
            for item_data in items_data:
                item_data.pop('sale', None)
                SaleItem.objects.create(
                    sale=instance,
                    product_name=item_data.get('product_name', item_data.get('productName', '')),
                    sku=item_data.get('sku'),
                    qty=int(item_data.get('qty', 1)),
                    price=float(item_data.get('price', 0.0)),
                    discount=float(item_data.get('discount', 0.0)),
                    total_price=float(item_data.get('total_price', item_data.get('totalPrice', 0.0)))
                )
        return instance

class PurchaseItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = PurchaseItem
        fields = '__all__'

class PurchaseSerializer(serializers.ModelSerializer):
    items = PurchaseItemSerializer(many=True, read_only=True)
    supplier_name = serializers.ReadOnlyField(source='supplier.name', default='')

    class Meta:
        model = Purchase
        fields = '__all__'

    def create(self, validated_data):
        # Allow nested creation of items from request data
        items_data = self.context.get('request').data.get('items', [])
        purchase = Purchase.objects.create(**validated_data)
        for item_data in items_data:
            item_data.pop('purchase', None)
            PurchaseItem.objects.create(purchase=purchase, **item_data)
        return purchase

    def update(self, instance, validated_data):
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()

        # Update PurchaseItems: delete existing ones and recreate
        items_data = self.context.get('request').data.get('items', [])
        if items_data:
            instance.items.all().delete()
            for item_data in items_data:
                item_data.pop('purchase', None)
                PurchaseItem.objects.create(
                    purchase=instance,
                    product_name=item_data.get('product_name', item_data.get('productName', '')),
                    sku=item_data.get('sku'),
                    qty=int(item_data.get('qty', 1)),
                    price=float(item_data.get('price', 0.0)),
                    discount=float(item_data.get('discount', 0.0)),
                    total_price=float(item_data.get('total_price', item_data.get('totalPrice', 0.0)))
                )
        return instance

from motors.models import Product

class ProductSerializer(serializers.ModelSerializer):
    class Meta:
        model = Product
        fields = '__all__'

from .models import Unit, SaleReturn, SaleReturnItem, PurchaseReturn, PurchaseReturnItem

class UnitSerializer(serializers.ModelSerializer):
    class Meta:
        model = Unit
        fields = '__all__'

class SaleReturnItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = SaleReturnItem
        fields = '__all__'

class SaleReturnSerializer(serializers.ModelSerializer):
    items = SaleReturnItemSerializer(many=True, read_only=True)
    class Meta:
        model = SaleReturn
        fields = '__all__'

    def create(self, validated_data):
        items_data = self.context.get('request').data.get('items', [])
        sale_return = SaleReturn.objects.create(**validated_data)
        for item_data in items_data:
            item_data.pop('sale_return', None)
            SaleReturnItem.objects.create(sale_return=sale_return, **item_data)
        return sale_return

class PurchaseReturnItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = PurchaseReturnItem
        fields = '__all__'

class PurchaseReturnSerializer(serializers.ModelSerializer):
    items = PurchaseReturnItemSerializer(many=True, read_only=True)
    class Meta:
        model = PurchaseReturn
        fields = '__all__'

    def create(self, validated_data):
        items_data = self.context.get('request').data.get('items', [])
        purchase_return = PurchaseReturn.objects.create(**validated_data)
        for item_data in items_data:
            item_data.pop('purchase_return', None)
            PurchaseReturnItem.objects.create(purchase_return=purchase_return, **item_data)
        return purchase_return

from .models import AreaManager

class AreaManagerSerializer(serializers.ModelSerializer):
    class Meta:
        model = AreaManager
        fields = '__all__'
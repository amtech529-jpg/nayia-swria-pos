from rest_framework import status, generics, permissions
from rest_framework.decorators import api_view, permission_classes, authentication_classes
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.authtoken.models import Token
from django.contrib.auth import login, logout
from django.utils import timezone
from datetime import timedelta
from django.db import transaction
from .models import User
from .serializers import (
    UserRegistrationSerializer,
    UserLoginSerializer,
    UserSerializer,
    ChangePasswordSerializer
)


@api_view(['POST'])
@authentication_classes([])
@permission_classes([AllowAny])
def register_user(request):
    """
    Register a new user
    """
    serializer = UserRegistrationSerializer(data=request.data)
    
    if serializer.is_valid():
        try:
            from django.db import connection
            print(f"REGISTER: Connecting to DB: {connection.settings_dict.get('NAME')}")
            with transaction.atomic():
                user = serializer.save()
                
                # Create authentication token (JWT)
                refresh = RefreshToken.for_user(user)
                
                return Response({
                    'success': True,
                    'message': 'User registered successfully.',
                    'data': {
                        'user': UserSerializer(user).data,
                        'token': str(refresh.access_token)
                    }
                }, status=status.HTTP_201_CREATED)
                
        except Exception as e:
            return Response({
                'success': False,
                'message': 'Registration failed due to server error.',
                'errors': {'detail': str(e)}
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    return Response({
        'success': False,
        'message': 'Registration failed.',
        'errors': serializer.errors
    }, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@authentication_classes([])
@permission_classes([AllowAny])
def login_user(request):
    """
    Login user with email and password
    """
    serializer = UserLoginSerializer(
        data=request.data,
        context={'request': request}
    )
    
    if serializer.is_valid():
        try:
            user = serializer.validated_data['user']
            
            # Update last login
            user.last_login = timezone.now()
            user.save(update_fields=['last_login'])
            
            # Get or create token (JWT)
            refresh = RefreshToken.for_user(user)
            
            # Login user (for session-based auth if needed)
            login(request, user)
            
            return Response({
                'success': True,
                'message': 'Login successful.',
                'data': {
                    'user': UserSerializer(user).data,
                    'token': str(refresh.access_token)
                }
            }, status=status.HTTP_200_OK)
            
        except Exception as e:
            return Response({
                'success': False,
                'message': 'Login failed due to server error.',
                'errors': {'detail': str(e)}
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    return Response({
        'success': False,
        'message': 'Login failed.',
        'errors': serializer.errors
    }, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([AllowAny])
def logout_user(request):
    """
    Logout user and delete token
    """
    try:
        # Delete the user's token
        token = Token.objects.get(user=request.user)
        token.delete()
        
        # Logout user from session
        logout(request)
        
        return Response({
            'success': True,
            'message': 'Logout successful.'
        }, status=status.HTTP_200_OK)
        
    except Token.DoesNotExist:
        # Token doesn't exist, but still logout the session
        logout(request)
        return Response({
            'success': True,
            'message': 'Logout successful.'
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Logout failed.',
            'error': str(e)
        }, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
@permission_classes([AllowAny])
def get_user_profile(request):
    """
    Get current user profile
    """
    serializer = UserSerializer(request.user)
    
    return Response({
        'success': True,
        'data': serializer.data
    }, status=status.HTTP_200_OK)


@api_view(['PUT', 'PATCH'])
@permission_classes([AllowAny])
def update_user_profile(request):
    """
    Update user profile
    """
    serializer = UserSerializer(
        request.user,
        data=request.data,
        partial=request.method == 'PATCH'
    )
    
    if serializer.is_valid():
        serializer.save()
        
        return Response({
            'success': True,
            'message': 'Profile updated successfully.',
            'data': serializer.data
        }, status=status.HTTP_200_OK)
    
    return Response({
        'success': False,
        'message': 'Profile update failed.',
        'errors': serializer.errors
    }, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([AllowAny])
def change_password(request):
    """
    Change user password
    """
    serializer = ChangePasswordSerializer(
        data=request.data,
        context={'request': request}
    )
    
    if serializer.is_valid():
        try:
            user = request.user
            user.set_password(serializer.validated_data['new_password'])
            user.save()
            
            # Create new JWT token for security
            refresh = RefreshToken.for_user(user)
            
            return Response({
                'success': True,
                'message': 'Password changed successfully.',
                'data': {
                    'token': str(refresh.access_token)
                }
            }, status=status.HTTP_200_OK)
            
        except Exception as e:
            return Response({
                'success': False,
                'message': 'Password change failed due to server error.',
                'errors': {'detail': str(e)}
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    return Response({
        'success': False,
        'message': 'Password change failed.',
        'errors': serializer.errors
    }, status=status.HTTP_400_BAD_REQUEST)


# Class-based views alternative (more DRF standard)
class UserRegistrationAPIView(generics.CreateAPIView):
    """Class-based view for user registration"""
    queryset = User.objects.all()
    serializer_class = UserRegistrationSerializer
    permission_classes = [AllowAny]
    
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        
        token, created = Token.objects.get_or_create(user=user)
        
        return Response({
            'success': True,
            'message': 'User registered successfully.',
            'data': {
                'user': UserSerializer(user).data,
                'token': token.key
            }
        }, status=status.HTTP_201_CREATED)


class UserProfileAPIView(generics.RetrieveUpdateAPIView):
    """Class-based view for user profile"""
    serializer_class = UserSerializer
    permission_classes = [AllowAny]
    
    def get_object(self):
        return self.request.user

@api_view(['GET', 'POST'])
@permission_classes([AllowAny])
def manage_users(request):
    """
    Manage user accounts (Sync support)
    """
    print(f"DEBUG: Request User: {request.user}, Authenticated: {request.user.is_authenticated}")
    if request.method == 'GET':
        users = User.objects.all()
        serializer = UserSerializer(users, many=True)
        return Response({'success': True, 'data': serializer.data})
    
    elif request.method == 'POST':
        email = request.data.get('email')
        if not email:
            return Response({'success': False, 'message': 'Email is required'}, status=status.HTTP_400_BAD_REQUEST)
            
        if User.objects.filter(email=email).exists():
            user = User.objects.get(email=email)
            return Response({'success': True, 'message': 'User exists', 'data': UserSerializer(user).data}, status=status.HTTP_200_OK)
        
        data = request.data.copy()
        if 'id' not in data:
            import uuid
            data['id'] = str(uuid.uuid4())
            
        serializer = UserSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response({'success': True, 'data': serializer.data}, status=status.HTTP_201_CREATED)
        return Response({'success': False, 'errors': serializer.errors}, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET', 'POST'])
@permission_classes([AllowAny])
def manage_logs(request):
    """
    Manage activity logs (Sync support)
    """
    print(f"DEBUG LOG: Request User: {request.user}, Auth: {request.user.is_authenticated}")
    if request.method == 'GET':
        logs = ActivityLog.objects.all().order_by('-timestamp')
        serializer = ActivityLogSerializer(logs, many=True)
        return Response({'success': True, 'data': serializer.data})
    
    elif request.method == 'POST':
        data = request.data.copy()
        if 'id' not in data:
            import uuid
            data['id'] = str(uuid.uuid4())
            
        serializer = ActivityLogSerializer(data=data)
        if serializer.is_valid():
            # Safer save to prevent 'User not found' on new accounts
            user = None
            if request.user and request.user.is_authenticated:
                user = request.user
            
            user_email = user.email if (user and hasattr(user, 'email')) else data.get('user_email', '')
            serializer.save(user=user, user_email=user_email)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


from django.db.models import Sum
from customers.models import Customer
from suppliers.models import Supplier
from .models import Sale, SaleItem, Purchase, PurchaseItem
from .serializers import SaleSerializer, PurchaseSerializer

@api_view(['GET', 'POST'])
@permission_classes([AllowAny])
def manage_sales(request):
    """
    List sales or create/update a sale invoice (UPSERT support)
    """
    if request.method == 'GET':
        sales = Sale.objects.filter(deleted=False).order_by('-sale_date')
        serializer = SaleSerializer(sales, many=True)
        return Response({'success': True, 'data': serializer.data})
    
    elif request.method == 'POST':
        # UPSERT support: If sale id already exists in database, treat as update
        sale_id = request.data.get('id')
        if sale_id and Sale.objects.filter(pk=sale_id).exists():
            sale = Sale.objects.get(pk=sale_id)
            serializer = SaleSerializer(sale, data=request.data, context={'request': request})
        else:
            serializer = SaleSerializer(data=request.data, context={'request': request})
            
        if serializer.is_valid():
            serializer.save()
            return Response({'success': True, 'data': serializer.data}, status=status.HTTP_201_CREATED)
        return Response({'success': False, 'errors': serializer.errors}, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET', 'PUT', 'PATCH', 'DELETE'])
@permission_classes([AllowAny])
def sale_detail(request, pk):
    """
    Retrieve, update, or soft-delete a sale invoice
    """
    try:
        sale = Sale.objects.get(pk=pk, deleted=False)
    except Sale.DoesNotExist:
        return Response({'success': False, 'message': 'Sale not found'}, status=status.HTTP_404_NOT_FOUND)

    if request.method == 'GET':
        serializer = SaleSerializer(sale)
        return Response({'success': True, 'data': serializer.data})
        
    elif request.method in ['PUT', 'PATCH']:
        serializer = SaleSerializer(sale, data=request.data, partial=(request.method == 'PATCH'), context={'request': request})
        if serializer.is_valid():
            serializer.save()
            return Response({'success': True, 'data': serializer.data})
        return Response({'success': False, 'errors': serializer.errors}, status=status.HTTP_400_BAD_REQUEST)
        
    elif request.method == 'DELETE':
        sale.deleted = True
        sale.save()
        return Response({'success': True, 'message': 'Sale deleted successfully'})


@api_view(['GET', 'POST'])
@permission_classes([AllowAny])
def manage_purchases(request):
    """
    List purchases or record/update a purchase invoice (UPSERT support)
    """
    if request.method == 'GET':
        purchases = Purchase.objects.filter(deleted=False).order_by('-purchase_date')
        serializer = PurchaseSerializer(purchases, many=True)
        return Response({'success': True, 'data': serializer.data})
    
    elif request.method == 'POST':
        purchase_id = request.data.get('id')
        if purchase_id and Purchase.objects.filter(pk=purchase_id).exists():
            purchase = Purchase.objects.get(pk=purchase_id)
            serializer = PurchaseSerializer(purchase, data=request.data, context={'request': request})
        else:
            serializer = PurchaseSerializer(data=request.data, context={'request': request})
            
        if serializer.is_valid():
            serializer.save()
            return Response({'success': True, 'data': serializer.data}, status=status.HTTP_201_CREATED)
        return Response({'success': False, 'errors': serializer.errors}, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET', 'PUT', 'PATCH', 'DELETE'])
@permission_classes([AllowAny])
def purchase_detail(request, pk):
    """
    Retrieve, update, or soft-delete a purchase invoice
    """
    try:
        purchase = Purchase.objects.get(pk=pk, deleted=False)
    except Purchase.DoesNotExist:
        return Response({'success': False, 'message': 'Purchase not found'}, status=status.HTTP_404_NOT_FOUND)

    if request.method == 'GET':
        serializer = PurchaseSerializer(purchase)
        return Response({'success': True, 'data': serializer.data})
        
    elif request.method in ['PUT', 'PATCH']:
        serializer = PurchaseSerializer(purchase, data=request.data, partial=(request.method == 'PATCH'), context={'request': request})
        if serializer.is_valid():
            serializer.save()
            return Response({'success': True, 'data': serializer.data})
        return Response({'success': False, 'errors': serializer.errors}, status=status.HTTP_400_BAD_REQUEST)
        
    elif request.method == 'DELETE':
        purchase.deleted = True
        purchase.save()
        return Response({'success': True, 'message': 'Purchase deleted successfully'})


@api_view(['GET'])
@permission_classes([AllowAny])
def pos_dashboard(request):
    """
    Retrieve dashboard statistics for sales, purchases, customers, and suppliers
    """
    try:
        # Aggregations
        total_sales = Sale.objects.filter(deleted=False).aggregate(total=Sum('net_total'))['total'] or 0.0
        total_purchases = Purchase.objects.filter(deleted=False).aggregate(total=Sum('net_total'))['total'] or 0.0
        
        customer_count = Customer.objects.filter(deleted=False).count()
        supplier_count = Supplier.objects.filter(deleted=False).count()
        
        # Recent items
        recent_sales = SaleSerializer(Sale.objects.filter(deleted=False).order_by('-sale_date')[:5], many=True).data
        recent_purchases = PurchaseSerializer(Purchase.objects.filter(deleted=False).order_by('-purchase_date')[:5], many=True).data
        
        return Response({
            'success': True,
            'data': {
                'total_sales': float(total_sales),
                'total_purchases': float(total_purchases),
                'customer_count': customer_count,
                'supplier_count': supplier_count,
                'recent_sales': recent_sales,
                'recent_purchases': recent_purchases,
            }
        })
    except Exception as e:
        return Response({
            'success': False,
            'message': f'Failed to retrieve dashboard data: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


from motors.models import Product
from .serializers import ProductSerializer

@api_view(['GET', 'POST'])
@permission_classes([AllowAny])
def manage_products(request):
    if request.method == 'GET':
        products = Product.objects.filter(deleted=False).order_by('-created_at')
        serializer = ProductSerializer(products, many=True)
        return Response(serializer.data)
    
    elif request.method == 'POST':
        data = request.data.copy()
        if 'id' not in data or not data['id']:
            import uuid
            data['id'] = str(uuid.uuid4())
        
        pk = data.get('id')
        try:
            product = Product.objects.get(pk=pk)
            serializer = ProductSerializer(product, data=data, partial=True)
        except Product.DoesNotExist:
            serializer = ProductSerializer(data=data)
            
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET', 'PUT', 'DELETE'])
@permission_classes([AllowAny])
def product_detail(request, pk):
    try:
        product = Product.objects.get(pk=pk, deleted=False)
    except Product.DoesNotExist:
        return Response({'message': 'Product not found'}, status=status.HTTP_404_NOT_FOUND)

    if request.method == 'GET':
        serializer = ProductSerializer(product)
        return Response(serializer.data)
        
    elif request.method == 'PUT':
        serializer = ProductSerializer(product, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
    elif request.method == 'DELETE':
        product.deleted = True
        product.save()
        return Response({'success': True, 'message': 'Product soft-deleted successfully'})

from .models import Unit
from .serializers import UnitSerializer, SaleReturnSerializer, PurchaseReturnSerializer

@api_view(['GET', 'POST'])
@permission_classes([AllowAny])
def manage_sale_returns(request):
    if request.method == 'GET':
        returns = SaleReturn.objects.filter(deleted=False).order_by('-return_date')
        serializer = SaleReturnSerializer(returns, many=True)
        return Response({'success': True, 'data': serializer.data})
        
    elif request.method == 'POST':
        serializer = SaleReturnSerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            serializer.save()
            return Response({'success': True, 'data': serializer.data}, status=status.HTTP_201_CREATED)
        return Response({'success': False, 'errors': serializer.errors}, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET', 'POST'])
@permission_classes([AllowAny])
def manage_purchase_returns(request):
    if request.method == 'GET':
        returns = PurchaseReturn.objects.filter(deleted=False).order_by('-return_date')
        serializer = PurchaseReturnSerializer(returns, many=True)
        return Response({'success': True, 'data': serializer.data})
        
    elif request.method == 'POST':
        serializer = PurchaseReturnSerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            serializer.save()
            return Response({'success': True, 'data': serializer.data}, status=status.HTTP_201_CREATED)
        return Response({'success': False, 'errors': serializer.errors}, status=status.HTTP_400_BAD_REQUEST)
@api_view(['GET', 'POST'])
@permission_classes([AllowAny])
def manage_units(request):
    if request.method == 'GET':
        units = Unit.objects.filter(deleted=False)
        serializer = UnitSerializer(units, many=True)
        return Response({'results': serializer.data})
        
    elif request.method == 'POST':
        data = request.data
        if not data.get('id'):
            import uuid
            data['id'] = str(uuid.uuid4())
            
        serializer = UnitSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET', 'PUT', 'DELETE'])
@permission_classes([AllowAny])
def unit_detail(request, pk):
    try:
        unit = Unit.objects.get(pk=pk, deleted=False)
    except Unit.DoesNotExist:
        return Response({'message': 'Unit not found'}, status=status.HTTP_404_NOT_FOUND)

    if request.method == 'GET':
        serializer = UnitSerializer(unit)
        return Response(serializer.data)
        
    elif request.method == 'PUT':
        serializer = UnitSerializer(unit, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
    elif request.method == 'DELETE':
        unit.deleted = True
        unit.save()
        return Response({'success': True, 'message': 'Unit soft-deleted successfully'})

from django.db.models import Sum
from django.utils import timezone
from datetime import timedelta
from .models import Sale, Purchase, SaleReturn, PurchaseReturn
from customers.models import Customer
from suppliers.models import Supplier

@api_view(['GET'])
@permission_classes([AllowAny])
def dashboard_stats(request):
    period = request.query_params.get('period', 'Today')
    location = request.query_params.get('location', 'All Locations')
    
    sales = Sale.objects.filter(deleted=False)
    purchases = Purchase.objects.filter(deleted=False)
    sale_returns = SaleReturn.objects.filter(deleted=False)
    purchase_returns = PurchaseReturn.objects.filter(deleted=False)
    
    if location != 'All Locations':
        sales = sales.filter(location__iexact=location)
        purchases = purchases.filter(location__iexact=location)
        # Assuming returns might not have location fields, we skip or filter if they do.
        
    now = timezone.localtime(timezone.now())
    if period == 'Today':
        today_start = now.replace(hour=0, minute=0, second=0, microsecond=0)
        today_end = today_start + timedelta(days=1)
        sales = sales.filter(sale_date__gte=today_start, sale_date__lt=today_end)
        purchases = purchases.filter(purchase_date__gte=today_start, purchase_date__lt=today_end)
        sale_returns = sale_returns.filter(return_date__gte=today_start, return_date__lt=today_end)
        purchase_returns = purchase_returns.filter(return_date__gte=today_start, return_date__lt=today_end)
    elif period == 'This Week':
        start_date = now - timedelta(days=7)
        sales = sales.filter(sale_date__gte=start_date)
        purchases = purchases.filter(purchase_date__gte=start_date)
        sale_returns = sale_returns.filter(return_date__gte=start_date)
        purchase_returns = purchase_returns.filter(return_date__gte=start_date)
    elif period == 'This Month':
        sales = sales.filter(sale_date__year=now.year, sale_date__month=now.month)
        purchases = purchases.filter(purchase_date__year=now.year, purchases__purchase_date__month=now.month)
        # Wait, Django models filter relation
        # Let's use purchase_date__year/month
        purchases = purchases.filter(purchase_date__year=now.year, purchase_date__month=now.month)
        sale_returns = sale_returns.filter(return_date__year=now.year, return_date__month=now.month)
        purchase_returns = purchase_returns.filter(return_date__year=now.year, return_date__month=now.month)
    elif period == 'This Year':
        sales = sales.filter(sale_date__year=now.year)
        purchases = purchases.filter(purchase_date__year=now.year)
        sale_returns = sale_returns.filter(return_date__year=now.year)
        purchase_returns = purchase_returns.filter(return_date__year=now.year)

    total_sales = sales.aggregate(total=Sum('net_total'))['total'] or 0.0
    total_sales_due = sales.aggregate(total=Sum('pending_amount'))['total'] or 0.0
    sales_received = sales.aggregate(total=Sum('paid_amount'))['total'] or 0.0
    total_discount = sales.aggregate(total=Sum('discount'))['total'] or 0.0
    
    total_purchases = purchases.aggregate(total=Sum('net_total'))['total'] or 0.0
    total_purchases_due = purchases.aggregate(total=Sum('pending_amount'))['total'] or 0.0
    purchases_paid = purchases.aggregate(total=Sum('paid_amount'))['total'] or 0.0
    
    total_sale_returns = sale_returns.aggregate(total=Sum('total_amount'))['total'] or 0.0
    total_purchase_returns = purchase_returns.aggregate(total=Sum('total_amount'))['total'] or 0.0

    # Compute COGS
    total_cogs = 0.0
    for sale in sales:
        for item in sale.items.all():
            prod = Product.objects.filter(name=item.product_name, deleted=False).first()
            if prod:
                item_cost = float(prod.cost)
            else:
                prod = Product.objects.filter(sku=item.sku, deleted=False).first() if item.sku else None
                if prod:
                    item_cost = float(prod.cost)
                else:
                    item_cost = float(item.price) * 0.7
            total_cogs += item_cost * item.qty

    gross_profit = float(total_sales) - total_cogs
    net_profit = gross_profit  # static expenses = 0 for now
    
    return Response({
        'total_sales': float(total_sales),
        'total_sales_due': float(total_sales_due),
        'sales_received': float(sales_received),
        'total_discount': float(total_discount),
        'total_purchases': float(total_purchases),
        'total_purchases_due': float(total_purchases_due),
        'purchases_paid': float(purchases_paid),
        'total_sale_returns': float(total_sale_returns),
        'total_purchase_returns': float(total_purchase_returns),
        'gross_profit': gross_profit,
        'net_profit': net_profit,
        'customer_count': Customer.objects.filter(deleted=False).count(),
        'supplier_count': Supplier.objects.filter(deleted=False).count(),
    })


class SaleReturnDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = SaleReturn.objects.filter(deleted=False)
    serializer_class = SaleReturnSerializer
    permission_classes = [AllowAny]


class PurchaseReturnListCreateView(generics.ListCreateAPIView):
    queryset = PurchaseReturn.objects.filter(deleted=False)
    serializer_class = PurchaseReturnSerializer
    permission_classes = [AllowAny]


class PurchaseReturnDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = PurchaseReturn.objects.filter(deleted=False)
    serializer_class = PurchaseReturnSerializer
    permission_classes = [AllowAny]


from .models import AreaManager
from .serializers import AreaManagerSerializer

@api_view(['GET', 'POST'])
@permission_classes([AllowAny])
def manage_area_managers(request):
    if request.method == 'GET':
        managers = AreaManager.objects.filter(deleted=False)
        serializer = AreaManagerSerializer(managers, many=True)
        return Response({'results': serializer.data})
        
    elif request.method == 'POST':
        data = request.data
        if not data.get('id'):
            import uuid
            data['id'] = str(uuid.uuid4())
            
        serializer = AreaManagerSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET', 'PUT', 'DELETE'])
@permission_classes([AllowAny])
def area_manager_detail(request, pk):
    try:
        manager = AreaManager.objects.get(pk=pk, deleted=False)
    except AreaManager.DoesNotExist:
        return Response({'message': 'Area Manager not found'}, status=status.HTTP_404_NOT_FOUND)

    if request.method == 'GET':
        serializer = AreaManagerSerializer(manager)
        return Response(serializer.data)
        
    elif request.method == 'PUT':
        serializer = AreaManagerSerializer(manager, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
    elif request.method == 'DELETE':
        manager.deleted = True
        manager.save()
        return Response({'success': True, 'message': 'Area Manager soft-deleted successfully'})
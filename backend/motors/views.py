from rest_framework import viewsets, permissions, status
from rest_framework.views import APIView
from rest_framework.response import Response
from django.db import transaction
from .models import Category, Customer, Supplier
from .serializers import CategorySerializer, CustomerSerializer, SupplierSerializer

class CategoryViewSet(viewsets.ModelViewSet):
    queryset = Category.objects.filter(deleted=False)
    serializer_class = CategorySerializer
    permission_classes = [permissions.AllowAny]

class CustomerViewSet(viewsets.ModelViewSet):
    queryset = Customer.objects.filter(deleted=False)
    serializer_class = CustomerSerializer
    permission_classes = [permissions.AllowAny]

class SupplierViewSet(viewsets.ModelViewSet):
    queryset = Supplier.objects.filter(deleted=False)
    serializer_class = SupplierSerializer
    permission_classes = [permissions.AllowAny]

class BulkSyncView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        action = request.query_params.get('action')
        if action != 'push':
            return Response({'success': False, 'message': 'Invalid action'}, status=400)
            
        data = request.data.get('tables', {})
        try:
            with transaction.atomic():
                for table_name, rows in data.items():
                    model = self._get_model(table_name)
                    if not model: 
                        continue
                    
                    for row in rows:
                        model.objects.update_or_create(
                            id=row['id'],
                            defaults=row
                        )
            return Response({'success': True, 'message': 'Sync successful'})
        except Exception as e:
            return Response({'success': False, 'message': str(e)}, status=500)

    def get(self, request):
        action = request.query_params.get('action')
        if action != 'pull':
            return Response({'success': False, 'message': 'Invalid action'}, status=400)
            
        last_sync = request.query_params.get('last_sync_at')
        tables_data = {}
        sync_tables = ['categories', 'customers', 'suppliers']
        
        for table in sync_tables:
            model = self._get_model(table)
            if not model: 
                continue
            
            queryset = model.objects.all()
            if last_sync:
                queryset = queryset.filter(updated_at__gt=last_sync)
            
            tables_data[table] = list(queryset.values())
            
        return Response({'success': True, 'tables': tables_data})

    def _get_model(self, table_name):
        mapping = {
            'categories': Category,
            'customers': Customer,
            'suppliers': Supplier
        }
        return mapping.get(table_name)

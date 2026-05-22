from rest_framework import viewsets, permissions
from .models import Supplier
from .serializers import SupplierSerializer

class SupplierViewSet(viewsets.ModelViewSet):
    queryset = Supplier.objects.filter(deleted=False)
    serializer_class = SupplierSerializer
    permission_classes = [permissions.AllowAny]

from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import *

router = DefaultRouter()
router.register(r'branches', BranchViewSet)
router.register(r'cities', CityViewSet)
router.register(r'areas', AreaViewSet)
router.register(r'casts', CasteViewSet)
router.register(r'guarantors', GuarantorViewSet)
router.register(r'customers', CustomerViewSet)
router.register(r'vendors', VendorViewSet)
router.register(r'staff', StaffViewSet)
router.register(r'brands', VehicleBrandViewSet)
router.register(r'colors', VehicleColorViewSet)
router.register(r'powers', VehiclePowerViewSet)
router.register(r'models', VehicleModelViewSet)
router.register(r'vehicles', VehicleViewSet)
router.register(r'invoices', InvoiceViewSet)
router.register(r'invoice-items', InvoiceItemViewSet)
router.register(r'installments', InstallmentViewSet)
router.register(r'transfers', StockTransferViewSet)
router.register(r'letters', LetterViewSet)
router.register(r'payment-vouchers', PaymentVoucherViewSet)
router.register(r'receipt-vouchers', ReceiptVoucherViewSet)
router.register(r'expenses', ExpenseViewSet)
router.register(r'reports', ReportViewSet, basename='reports')
router.register(r'logs', ActivityLogViewSet)

urlpatterns = [
    path('sync/', BulkSyncView.as_view(), name='bulk-sync'),
    path('', include(router.urls)),
]

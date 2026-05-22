from django.urls import path, include
from . import views

# URL patterns for the posapi app
urlpatterns = [
    # Authentication endpoints
    path('auth/register/', views.register_user, name='register'),
    path('auth/login/', views.login_user, name='login'),
    path('auth/logout/', views.logout_user, name='logout'),
    
    # User profile endpoints
    path('auth/profile/', views.get_user_profile, name='user-profile'),
    path('auth/profile/update/', views.update_user_profile, name='update-profile'),
    path('auth/change-password/', views.change_password, name='change-password'),
    path('auth/users/', views.manage_users, name='manage-users'),
    
    # Sales endpoints
    path('sales/', views.manage_sales, name='manage-sales'),
    path('sale-returns/<str:pk>/', views.SaleReturnDetailView.as_view(), name='sale_return_detail'),
    path('purchase-returns/', views.PurchaseReturnListCreateView.as_view(), name='purchase_return_list'),
    path('purchase-returns/<str:pk>/', views.PurchaseReturnDetailView.as_view(), name='purchase_return_detail'),
    path('dashboard-stats/', views.dashboard_stats, name='dashboard_stats'),
    path('sales/<str:pk>/', views.sale_detail, name='sale-detail'),

    # Purchases endpoints
    path('purchases/', views.manage_purchases, name='manage-purchases'),
    path('purchases/<str:pk>/', views.purchase_detail, name='purchase-detail'),

    # Dashboard endpoint
    path('dashboard/', views.pos_dashboard, name='pos-dashboard'),

    # Products endpoints
    path('products/', views.manage_products, name='manage-products'),
    path('products/<str:pk>/', views.product_detail, name='product-detail'),
    
    # Returns endpoints
    path('sale-returns/', views.manage_sale_returns, name='manage-sale-returns'),
    path('purchase-returns/', views.manage_purchase_returns, name='manage-purchase-returns'),

    # Units endpoints
    path('units/', views.manage_units, name='manage-units'),
    path('units/<str:pk>/', views.unit_detail, name='unit-detail'),
    
    # Area Managers endpoints
    path('area-managers/', views.manage_area_managers, name='manage-area-managers'),
    path('area-managers/<str:pk>/', views.area_manager_detail, name='area-manager-detail'),
]

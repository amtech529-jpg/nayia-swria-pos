from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from django.views.generic import RedirectView

urlpatterns = [
    # 2. Add this line to redirect the empty Homepage to Admin
    path('', RedirectView.as_view(url='/admin/', permanent=False)),

    path('admin/', admin.site.urls),
    path('api/v1/', include('posapi.urls')),
    path('api/v1/categories/', include('categories.urls')),
    path('api/v1/customers/', include('customers.urls')),
    path('api/v1/suppliers/', include('suppliers.urls')),
]

# Serve media files during development
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
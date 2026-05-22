#!/usr/bin/env python
"""
Railway startup script - creates admin user if it doesn't exist
Run as part of Railway release command
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')
django.setup()

from posapi.models import User

ADMIN_EMAIL = os.environ.get('ADMIN_EMAIL', 'admin@nayia.com')
ADMIN_PASSWORD = os.environ.get('ADMIN_PASSWORD', 'Admin@123')
ADMIN_NAME = os.environ.get('ADMIN_NAME', 'Admin')

if not User.objects.filter(email=ADMIN_EMAIL).exists():
    User.objects.create_superuser(
        email=ADMIN_EMAIL,
        password=ADMIN_PASSWORD,
        full_name=ADMIN_NAME
    )
    print(f"✅ Admin user created: {ADMIN_EMAIL}")
else:
    print(f"ℹ️  Admin user already exists: {ADMIN_EMAIL}")

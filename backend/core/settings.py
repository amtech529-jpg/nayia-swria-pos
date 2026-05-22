from pathlib import Path
import os
import dj_database_url
from decouple import config, Csv

BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = config('SECRET_KEY', default='django-insecure-default-key-change-me')
if SECRET_KEY == 'django-insecure-default-key-change-me':
    print("SECRET_KEY: WARNING! Using default insecure key. Tokens will be unstable.")
else:
    print(f"SECRET_KEY: Custom key loaded successfully (Starts with: {SECRET_KEY[:4]}...)")

DEBUG = config('DEBUG', default=True, cast=bool)

# Allows local dev and Railway's dynamic domain
ALLOWED_HOSTS = config(
    'ALLOWED_HOSTS', 
    default='127.0.0.1,localhost,.railway.app,*.up.railway.app', 
    cast=Csv()
)

# Railway CSRF - accept any railway.app subdomain
_RAILWAY_URL = config('RAILWAY_PUBLIC_DOMAIN', default='')
CSRF_TRUSTED_ORIGINS = [
    'https://*.railway.app',
    'https://*.up.railway.app',
] + ([f'https://{_RAILWAY_URL}'] if _RAILWAY_URL else [])

INSTALLED_APPS = [
    'daphne',  # ASGI server
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework',
    'rest_framework_simplejwt',
    'rest_framework.authtoken',
    'corsheaders',
    'channels',
    # Your Apps
    'posapi',
    'categories',
    'customers',
    'suppliers',
    'motors',
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware',  # For Railway static files
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'core.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'core.wsgi.application'
ASGI_APPLICATION = 'core.asgi.application'

# --- DATABASE CONFIGURATION ---
# This logic prevents UndefinedValueError on Railway
# We prefer DATABASE_PUBLIC_URL to avoid Railway's internal DNS issues
DATABASE_URL = config('DATABASE_PUBLIC_URL', default=config('DATABASE_URL', default=None))

if DATABASE_URL:
    # Safely extract host for logging
    import re
    host_match = re.search(r'@(.*?)(?::|/|$)', DATABASE_URL)
    db_host = host_match.group(1) if host_match else "unknown"
    print(f"DATABASE: Attempting to connect to host: {db_host}")
    
    DATABASES = {
        'default': dj_database_url.config(
            default=DATABASE_URL,
            conn_max_age=600,
            conn_health_checks=True,
            ssl_require=False # Railway internal often doesn't like forced SSL
        )
    }
else:
    print(f"DATABASE: WARNING! Using fallback local SQLite (Development mode)")
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.sqlite3',
            'NAME': BASE_DIR / 'db.sqlite3',
        }
    }

# --- CHANNELS ---
CHANNEL_LAYERS = {
    "default": {
        "BACKEND": "channels.layers.InMemoryChannelLayer"
    }
}

AUTH_USER_MODEL = 'posapi.User'

AUTHENTICATION_BACKENDS = [
    'posapi.admin_backend.AdminBackend',
    'django.contrib.auth.backends.ModelBackend',
]

AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator', 'OPTIONS': {'min_length': 8}},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True

# --- STATIC & MEDIA ---
STATIC_URL = 'static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')
# This allows Whitenoise to serve compressed files
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'

MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# --- REST FRAMEWORK ---
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
        'rest_framework.authentication.SessionAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.AllowAny',
    ],
    'DEFAULT_THROTTLE_CLASSES': [
        'rest_framework.throttling.UserRateThrottle',
    ],
    'DEFAULT_THROTTLE_RATES' : {
        'user': '1000/hour',
        'dashboard': '60/minute',
    },
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
    'MAX_PAGE_SIZE': 100,
}

from datetime import timedelta
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(days=7),    # 7 din tak valid
    'REFRESH_TOKEN_LIFETIME': timedelta(days=30),  # 30 din refresh
    'ROTATE_REFRESH_TOKENS': False,
    'BLACKLIST_AFTER_ROTATION': True,
    'ALGORITHM': 'HS256',
    'SIGNING_KEY': SECRET_KEY,
    'VERIFYING_KEY': None,
    'AUTH_HEADER_TYPES': ('Bearer', 'JWT'),
    'USER_ID_FIELD': 'id',
    'USER_ID_CLAIM': 'user_id',
    'AUTH_TOKEN_CLASSES': ('rest_framework_simplejwt.tokens.AccessToken',),
}

# --- CORS ---
CORS_ALLOW_ALL_ORIGINS = True  # Simpler for your first Railway deploy
CORS_ALLOW_CREDENTIALS = True

# --- LOGGING (Railway Optimized) ---
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {module} {message}',
            'style': '{',
        },
    },
    'handlers': {
        'console': {
            'level': 'INFO',
            'class': 'logging.StreamHandler',
            'formatter': 'verbose',
        },
    },
    'loggers': {
        'django': {
            'handlers': ['console'],
            'level': 'INFO',
        },
        'advance_payments': {
            'handlers': ['console'],
            'level': 'INFO',
            'propagate': True,
        },
        'expenses': {
            'handlers': ['console'],
            'level': 'INFO',
            'propagate': True,
        },
    },
}

# --- COMPANY DETAILS (For Receipts/Invoices) ---
COMPANY_NAME = 'AL NOOR CLOTH HOUSE'
COMPANY_ADDRESS = 'Block 10 DGKhan'
COMPANY_PHONE = '03344891100, 03336461731'
from rest_framework import serializers
from .models import Category

class CategorySerializer(serializers.ModelSerializer):
    parent_id = serializers.PrimaryKeyRelatedField(
        queryset=Category.objects.all(), source='parent', required=False, allow_null=True
    )
    parent_name = serializers.CharField(source='parent.name', read_only=True)

    class Meta:
        model = Category
        fields = ['id', 'name', 'description', 'parent', 'parent_id', 'parent_name', 'created_at', 'updated_at', 'deleted']

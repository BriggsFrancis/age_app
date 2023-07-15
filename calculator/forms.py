from django.forms import ModelForm 
from calculator.models import Data


class UserDataForm(ModelForm):

    class Meta:
        model=Data
        fields='__all__'

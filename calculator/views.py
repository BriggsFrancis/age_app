from django.shortcuts import render,redirect,get_object_or_404
from django.contrib import messages
from calculator.models import Data
# from django.http import HttpResponse
# import datetime

from calculator.forms import UserDataForm

def home(request):
    if request.method == 'POST':
        form=UserDataForm(request.POST)
        if form.is_valid():
            name=form.cleaned_data['name']
            msg=f'{name} Your details age has been calculated'
            messages.success(request,msg)
            return redirect('result',name=name,permanent=True)
        else:
            msg= f'Invalid form'
            messages.error(request,msg)
            return redirect('home',permanent=True)
    
    else:
        form=UserDataForm()
    
    return render(request,"age_calc/home.html",{'form':form})
   
def result(request,name):
    name=get_object_or_404(Data,name=name)
    context={
    'age_seconds':name.calculate_age_seconds(),
    'age_minutes':name.calculate_age_minutes(),
    'age_hours':name.calculate_age_hours(),
    'age_days':name.calculate_age_days(),
    'age_weeks':name.calculate_age_weeks(),
    'age_years':name.calculate_age_years(),
    }
    return render(request,'age_calc/result.html',context=context)


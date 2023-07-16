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
            form.save()
            name=form.cleaned_data['name']
            msg=f'{name} Your details age has been calculated'
            messages.success(request,msg)
            return redirect('result',name=name)
        else:
            msg= f'Invalid form'
            messages.error(request,msg)
            return redirect('home')
    
    else:
        form=UserDataForm()
    
    return render(request,"calculator/form.html",{'form':form})
   
def result(request,name):
    name_obj=get_object_or_404(Data,name=name)
    context={
        'name': name_obj.name,
        'age_seconds':name_obj.calculate_age_seconds(),
        'age_minutes':name_obj.calculate_age_minutes(),
        'age_hours':name_obj.calculate_age_hours(),
        'age_days':name_obj.calculate_age_days(),
        'age_weeks':name_obj.calculate_age_weeks(),
        'age_years':name_obj.calculate_age_years(),
        'generation': name_obj.generation()
    }
    return render(request,'calculator/result.html',context=context)


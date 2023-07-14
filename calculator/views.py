from django.shortcuts import render
from django.http import HttpResponse
import datetime
# Create your views here.

def home(request):
    now=datetime.dateime.now()
    html="<html><body> It is now %s </body></html>" % now 
    return HttpResponse(html)

from django.db import models
from datetime import datetime
from django.core.exceptions import ValidationError
# Create your models here.

# def validate_datetime_format(value):
#     #To make sure user input is in correct format
#     desired_format= "%Y/%m/%d"
#     try:
#         datetime.strptime(value,desired_format)
#     except ValueError:
#         raise ValidationError("invalid Format it should be written as YYYY/MM/DD")

def validate_name(value):
    if not value.isalpha():
        raise ValidationError('Use only alphabets')


class Data(models.Model):
    '''
    This is to store user data 
    '''
    name= models.CharField(max_length=100,null=False,default='',validators=[validate_name])
    age=models.DateTimeField() #validators=[validate_datetime_format]
    now=models.DateTimeField(auto_now=True)

    def calculate_age_seconds(self):
        time_diff=self.now-self.age
        total_seconds=time_diff.total_seconds()
        return total_seconds
    
    def calculate_age_minutes(self):
        age_in_seconds= self.calculate_age_seconds()
        age_in_minutes=age_in_seconds/60
        return age_in_minutes 
    
    def calculate_age_hours(self):
        age_in_minutes= self.calculate_age_minutes()
        age_in_hours=age_in_minutes/60
        return age_in_hours
    
    def calculate_age_days(self):
        age_in_hours=self.calculate_age_hours()
        age_in_days=age_in_hours//24
        return age_in_days
    
    def calculate_age_weeks(self):
        age_in_days=self.calculate_age_days()
        age_in_weeks=age_in_days//7
        return age_in_weeks
    
    def calculate_age_years(self):
        age_in_weeks=self.calculate_age_weeks()
        age_in_years=age_in_weeks//52
        return age_in_years



    def __str__(self):
        return self.name
# Generated by Django 4.2.3 on 2023-07-15 15:12

import datetime
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('calculator', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='data',
            name='gen_alpha_lower',
            field=models.DateTimeField(default=datetime.datetime(2013, 1, 1, 0, 0)),
        ),
        migrations.AddField(
            model_name='data',
            name='gen_alpha_upper',
            field=models.DateTimeField(default=datetime.datetime(2025, 1, 1, 0, 0)),
        ),
        migrations.AddField(
            model_name='data',
            name='gen_z_lower',
            field=models.DateTimeField(default=datetime.datetime(1995, 1, 1, 0, 0)),
        ),
        migrations.AddField(
            model_name='data',
            name='gen_z_upper',
            field=models.DateTimeField(default=datetime.datetime(2012, 1, 1, 0, 0)),
        ),
        migrations.AddField(
            model_name='data',
            name='millennials_lower',
            field=models.DateTimeField(default=datetime.datetime(1994, 1, 1, 0, 0)),
        ),
        migrations.AddField(
            model_name='data',
            name='millennials_upper',
            field=models.DateTimeField(default=datetime.datetime(1980, 1, 1, 0, 0)),
        ),
    ]

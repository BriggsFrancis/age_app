# Generated by Django 4.2.3 on 2023-07-15 13:51

import calculator.models
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Data',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(default='', max_length=100, validators=[calculator.models.validate_name])),
                ('age', models.DateTimeField()),
                ('now', models.DateTimeField(auto_now=True)),
            ],
        ),
    ]

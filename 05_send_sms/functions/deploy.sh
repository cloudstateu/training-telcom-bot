#!/bin/bash

zip -r deploy.zip host.json node_modules package*.json sms

az functionapp deployment source config-zip -g rg-pgg-telcomapp-<student_name> -n func-telcomapp --src deploy.zip

rm deploy.zip
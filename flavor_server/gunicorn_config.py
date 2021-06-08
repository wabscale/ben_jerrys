from os import environ

PORT=environ.pop('PORT')
WORKERS=environ.pop('WORKERS')
SITENAME=environ.pop('SITENAME')

bind='0.0.0.0:{}'.format(PORT)
workers=int(WORKERS)
log_level='DEBUG'
errorlog='web/data/error.log'
application='web:app'

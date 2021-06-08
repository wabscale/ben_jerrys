from flask import Flask, render_template, request, redirect, g, Blueprint, send_from_directory
from flask_login import current_user, login_required
from flask_sqlalchemy import SQLAlchemy
from flask_bootstrap import Bootstrap
from flask_wtf import CSRFProtect
import os
import subprocess
import json

from .config import Config

host = '0.0.0.0'
port = 5000

app = Flask(__name__, static_url_path='/static')
app.config.from_object(Config)

Bootstrap(app)
CSRFProtect(app)
db = SQLAlchemy(app)


# register blueprints
from .auth import auth
app.register_blueprint(auth)

def get_flavordata():
    return json.loads(open('FlavorData.json').read())

def syscall(cmd):
    return subprocess.check_output(cmd, shell=True).decode().strip()

def sort_flavors(flavordata):
    for sublist in flavordata.values():
        sublist.sort()
    return flavordata


def write_flavor_data(flavordata):
    print('write')
    flavordata=sort_flavors(flavordata)
    with open('FlavorData.json', 'w') as f:
        f.write(json.dumps(flavordata, indent=2))


def add_flavor(flavorname, allergy_list):
    flavordata=get_flavordata()
    if flavorname in flavordata['All']:
        remove_flavor(flavorname)
    flavordata['All'].append(flavorname)
    for allergy_item in allergy_list:
        flavordata[allergy_item.replace(' ', '_')].append(flavorname)
    write_flavor_data(flavordata)


def remove_flavor(flavorname):
    flavordata=get_flavordata()
    for sublist in flavordata.values():
        if flavorname in sublist:
            sublist.remove(flavorname)

    def rm(filename):
        if os.path.isfile(filename):
            os.remove(filename)

    rm('web/static/img/{flavorname}.jpeg'.format(flavorname=flavorname))
    rm('web/static/img/{flavorname}Icon.jpeg'.format(flavorname=flavorname))
    write_flavor_data(flavordata)


def save_image(image_name, image_file):
    pwd = syscall('pwd')
    image_file.save('{pwd}/web/static/img/{image_name}'.format(pwd=pwd,image_name=image_name))


def truncated_allergy_list():
    flavordata=get_flavordata()
    allergylist = flavordata['Allergy'][:]
    allergylist.remove('Gluten')
    allergylist.remove('Vegan')
    return allergylist


def validate_form(lst, index=0):
    flag = False
    if lst[index] in request.form:
        flag = request.form[lst[index]] != ''
    elif lst[index] in request.files:
        flag = request.files[lst[index]] != ''
    if len(lst) == index + 1:
        return flag
    return flag and validate_form(lst, index+1)


@app.route('/images/<image_name>')
def serve_image(image_name):
    return send_from_directory('static/img', image_name)


@app.route('/FlavorData.json')
def serve_flavordata():
    flavordata=get_flavordata()
    return json.dumps(flavordata)
    #return send_from_directory('./', 'FlavorData.json')


@app.route('/')
@login_required
def index():
    flavordata=get_flavordata()
    return render_template('index.html', flavordata=flavordata)


@app.route('/newflavor.html', methods=['GET', 'POST'])
@login_required
def newflavorhtml():
    flavordata=get_flavordata()
    if request.method == "POST": # handle upload
        if validate_form(['flavorname', 'nutritional_img', 'tag_img']):
            # https://stackoverflow.com/questions/44926465/upload-image-in-flask#44926557
            flavorname = request.form.get('flavorname')
            save_image('{flavorname}.jpeg'.format(flavorname=flavorname), request.files.get('nutritional_img'))
            save_image('{flavorname}Icon.jpeg'.format(flavorname=flavorname), request.files.get('tag_img'))

            sublists = []
            for flavor_type in flavordata['Types']:
                if flavor_type in request.form:
                    sublists.append(flavor_type)
            for allergy_type in flavordata['Allergy']:
                if allergy_type in request.form:
                    sublists.append(allergy_type)

            add_flavor(flavorname, sublists)
        else:
            print('error in adding new flavor')

    return render_template(
        'newflavor.html',
        flavortypes=flavordata['Types'],
        allergylist=truncated_allergy_list(),
    )


@app.route('/removeflavor.html', methods=['GET', 'POST'])
@login_required
def removeflavorhtml():
    if request.method == "POST":
        flavorname = request.form.get('flavorname')
        remove_flavor(flavorname)
    flavordata=get_flavordata()
    return render_template('removeflavor.html', flavornames=flavordata['All'])

if __name__ == '__main__':
    app.run(
        debug=True,
        host=host,
        port=port
    )

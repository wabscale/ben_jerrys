#!/usr/bin/python3
from flask import *
import json
from colorama import Fore, Style
import subprocess
import socket
import os
import pyfiglet

app = Flask(__name__)

flavordata = json.loads(open('FlavorData.json').read())
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.connect(("8.8.8.8", 80))
hostname = s.getsockname()[0]
s.close()


def syscall(cmd):
    return subprocess.check_output(cmd, shell=True).decode().strip()


def colorize(msg, color):
    return Fore.__dict__[color.upper()] + msg + Style.RESET_ALL


def sort_flavors():
    for sublist in flavordata.values():
        sublist.sort()


def write_flavor_data():
    print('write')
    sort_flavors()
    with open('FlavorData.json', 'w') as f:
        f.write(json.dumps(flavordata, indent=2))


def add_flavor(flavorname, allergy_list):
    if flavorname in flavordata['All']:
        remove_flavor(flavorname)
    flavordata['All'].append(flavorname)
    for allergy_item in allergy_list:
        flavordata[allergy_item.replace(' ', '_')].append(flavorname)
    print(colorize('[+]', 'green'), flavorname)
    write_flavor_data()


def remove_flavor(flavorname):
    for sublist in flavordata.values():
        if flavorname in sublist:
            sublist.remove(flavorname)

    def rm(filename):
        if os.path.isfile(filename):
            os.remove(filename)

    rm(f'static/img/{flavorname}.jpeg')
    rm(f'static/img/{flavorname}Icon.jpeg')
    write_flavor_data() 


def save_image(image_name, image_file):
    pwd = syscall('pwd')
    image_file.save(f'{pwd}/static/img/{image_name}')


def truncated_allergy_list():
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
    return json.dumps(flavordata)
    #return send_from_directory('./', 'FlavorData.json')


@app.route('/')
def index():
    return render_template('index.html', flavordata=flavordata, hostname=hostname)


@app.route('/newflavor.html', methods=['GET', 'POST'])
def newflavorhtml():
    if request.method == "POST": # handle upload
        if validate_form(['flavorname', 'nutritional_img', 'tag_img']):
            # https://stackoverflow.com/questions/44926465/upload-image-in-flask#44926557
            flavorname = request.form.get('flavorname')
            save_image(f'{flavorname}.jpeg', request.files.get('nutritional_img'))
            save_image(f'{flavorname}Icon.jpeg', request.files.get('tag_img'))

            sublists = []
            for flavor_type in flavordata['Types']:
                if flavor_type in request.form:
                    sublists.append(flavor_type)
            for allergy_type in flavordata['Allergy']:
                if allergy_type in request.form:
                    sublists.append(allergy_type)

            add_flavor(flavorname, sublists)
        else:
            print(colorize('[-]', 'red'), f'error in adding new flavor')

    return render_template(
        'newflavor.html',
        flavortypes=flavordata['Types'],
        allergylist=truncated_allergy_list(),
        hostname=hostname,
    )


@app.route('/removeflavor.html', methods=['GET', 'POST'])
def removeflavorhtml():
    if request.method == "POST":
        flavorname = request.form.get('flavorname')
        remove_flavor(flavorname)
    return render_template('removeflavor.html', hostname=hostname)


if __name__ == "__main__":
    print()
    print(pyfiglet.figlet_format('BJ\'s App Server', font='slant', width=100))
    print('link to website --> http://localhost:5000 <--', '\n\n\n')
    app.run(host='0.0.0.0', port=5000)

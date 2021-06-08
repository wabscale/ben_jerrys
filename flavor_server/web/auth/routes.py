from flask import request, redirect, url_for, flash, render_template, Blueprint
from flask_login import current_user, login_user, logout_user, login_required
from sqlalchemy.exc import IntegrityError

from .forms import LoginForm, RegistrationForm

from ..app import db
from ..models import User

auth = Blueprint('auth', __name__, url_prefix='/auth')


#@auth.route('/register', methods=['GET', 'POST'])
def register():
    if current_user.is_authenticated:
        return redirect(url_for('index'))
    form = RegistrationForm()
    if form.validate_on_submit():
        try:
            u = User(username=form.username.data)
            u.set_password(form.password.data)
            db.session.add(u)
            db.session.commit()
            login_user(u)
            return redirect(url_for('index'))
        except IntegrityError:
            db.session.rollback()
            flash('Username already in use')
            return render_template('auth/register.html', form=form)
    return render_template('auth/register.html', form=form)


@auth.route('/login', methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('index'))
    form = LoginForm()
    if form.validate_on_submit():
        u = (User.query.filter_by(username=form.username.data)).first()
        if u is None or not u.check_password(form.password.data):
            flash('Invalid username or password')
            return render_template('auth/login.html', form=form)
        login_user(u)
        return redirect(url_for('index'))
    return render_template('auth/login.html', form=form)


@auth.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect(url_for('index'))

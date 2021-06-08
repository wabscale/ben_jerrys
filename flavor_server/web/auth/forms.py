from flask_wtf import FlaskForm
from wtforms.fields import TextField, PasswordField, SubmitField
from wtforms.validators import Required


class RegistrationForm(FlaskForm):
    username = TextField("Username", validators=[Required()])
    password = PasswordField("Password", validators=[Required()])
    submit = SubmitField("Register")


class LoginForm(FlaskForm):
    username = TextField("Username", validators=[Required()])
    password = PasswordField("Password", validators=[Required()])
    submit = SubmitField("Login")

from web import app, db

db.create_all()
app.run(
    debug=True,
    host='0.0.0.0',
    port=5000,
)

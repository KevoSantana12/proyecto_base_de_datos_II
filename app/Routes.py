from flask import render_template, request, current_app as app
from Business import Logica
from Entities import User

logicaCRUD = Logica()

@app.route("/")
def main():
    return render_template("index.html")

@app.route("/form", methods=['POST'])
def form():
    nombre = request['nombre']
    edad = request['edad']
    user = User(nombre=nombre, edad=edad)
    result = Logica.saveUser(user)
    return render_template('result.html', result = result)


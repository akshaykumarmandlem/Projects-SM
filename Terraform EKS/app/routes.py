from flask import Blueprint, render_template
from .kubernetes_detection import analyze_kubernetes_threats

main = Blueprint('main', __name__)

@main.route('/')
def index():
    threats = analyze_kubernetes_threats()
    return render_template('index.html', threats=threats)
from flask import Blueprint, render_template, request, flash, jsonify
from flask_login import login_required, current_user
from .models import Note
from . import db
import json

views = Blueprint('views', __name__)

@views.route('/', methods=['GET', 'POST'])
@login_required
def home():
    if request.method == "POST":
        note = request.form.get('note')
        if len(note) < 1:
            flash("Note is too short!", category="error")
        else:
            new_note = Note(data=note, user_id=current_user.id)
            db.session.add(new_note)
            db.session.commit()
            flash('Note added!', category="success")

    # Retrieve all notes belonging to the current user
    user_notes = Note.query.filter_by(user_id=current_user.id).all()
    return render_template("home.html", user=current_user, notes=user_notes)

@views.route('/delete-note', methods=['POST'])
def delete_note():  
    note_data = json.loads(request.data)
    note_id = note_data['noteId']
    note = Note.query.get(note_id)
    if note:
        if note.user_id == current_user.id:
            db.session.delete(note)
            db.session.commit()
            flash('Note deleted successfully', category='success')
            return jsonify({'message': 'Note deleted successfully'})

    return jsonify({'message': 'Note deletion failed'})

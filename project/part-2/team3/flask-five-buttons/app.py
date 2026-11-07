from flask import Flask, abort, jsonify, render_template, request

from actions import BUTTONS

app = Flask(__name__)


@app.get("/")
def home():
    return render_template("index.html", buttons=BUTTONS)


@app.post("/actions/<int:button_id>")
def run_action(button_id):
    if button_id not in BUTTONS:
        abort(404)

    # Require the panel header so other sites cannot trigger actions with a form.
    if request.headers.get("X-Button-Panel") != "1":
        abort(403)

    label, action = BUTTONS[button_id]
    result = action()
    message = f"{label} completed." if result is None else str(result)
    return jsonify(message=message)


if __name__ == "__main__":
    app.run()

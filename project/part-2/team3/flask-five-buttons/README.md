# Flask Button Panel

A local Flask app with five buttons. Each button runs a separate Python
function and displays its result on the page.

## Run it on Windows

Extract the ZIP, open the `flask-five-buttons` folder, and open Command Prompt
or PowerShell in that folder. Run these commands with Python 3.9 or newer.

```powershell
py -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\.venv\Scripts\python.exe app.py
```

On macOS or Linux, run these commands from the same folder.

```bash
python3 -m venv .venv
.venv/bin/python -m pip install -r requirements.txt
.venv/bin/python app.py
```

Open [http://127.0.0.1:5000](http://127.0.0.1:5000) and click a button.
Press Ctrl+C in the terminal to stop the app.

## Program a button

Open `actions.py` and replace the body of `button_one()` through
`button_five()`. The return value becomes the result shown on the page.
A function that returns nothing shows a default completion message.

For example, Button 1 can display the server's current time.

```python
from datetime import datetime


def button_one():
    return datetime.now().strftime("Current time is %I:%M %p")
```

Put the import at the top of `actions.py`. Change the text in the
`BUTTONS` dictionary to rename any button. Save your edits, restart Flask,
and refresh the page.

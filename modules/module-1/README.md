# Module 1: Library Admin -- Books

A tiny Python web app that serves a page of sample admin books. It uses
only Python's standard library, so there's nothing to `pip install` --
it runs the moment `python3` is available on the VM.

## Getting it onto your Ubuntu VM

```
sudo apt-get update
sudo apt-get install -y git
cd ~
git clone https://github.com/SE4CPS/2026-COMP-175.git
cd 2026-COMP-175/modules/module-1
```

## Running it

```
python3 app.py
```

Then browse to `http://<server-ip>:8080/` from another machine on the
same network (or `http://localhost:8080/` if you're on the VM itself).
Press `Ctrl+C` to stop it.

## Pulling updates

```
cd ~/2026-COMP-175
git pull
```

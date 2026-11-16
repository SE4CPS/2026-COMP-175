# Module 13 Practice Lab: Containerize It

Sample files for the Module 13 (Containerization) Practice Lab.

- `app.py` -- the small Python app being containerized.
- `Dockerfile` -- builds a `python:3.12-slim` image, copies `app.py` in,
  and runs it as the container's entrypoint.

Clone this repo and `cd` into this folder, then build and run:

```
docker build -t my-script:1.0 .
docker run my-script:1.0
```

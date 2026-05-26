# Pipeline UI (FastAPI)

Local web UI to run the slide pipeline step-by-step and edit storyboard ideas per page.

## Run

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r apps/pipeline_ui/requirements.txt
uvicorn apps.pipeline_ui.app.main:app --reload --port 8000
```

Open `http://127.0.0.1:8000`.


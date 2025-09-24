FROM python:3.12 AS builder

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

ENV UV_LINK_MODE=copy \
    UV_PROJECT_ENVIRONMENT=/opt/venv \
    UV_PYTHON_DOWNLOADS=never

RUN --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --no-dev --no-install-project

FROM python:3.12-slim

ENV PYTHONPATH=/opt/venv/lib/python3.12/site-packages \
    PATH="/opt/venv/bin:$PATH" \
    PYTHONUNBUFFERED=1

WORKDIR /app

COPY . /app

COPY --from=builder /opt/venv /opt/venv

# VOLUME ["/app/tasks.db"] # Would need to make the DB path configurable or seperate from the root of the app

EXPOSE 8000

CMD ["python", "-m", "uvicorn", "cc_simple_server.server:app", "--host", "0.0.0.0", "--port", "8000"]

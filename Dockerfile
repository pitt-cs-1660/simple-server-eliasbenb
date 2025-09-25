FROM python:3.12 AS builder

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

ENV UV_LINK_MODE=copy \
    UV_PROJECT_ENVIRONMENT=/opt/venv \
    UV_PYTHON_DOWNLOADS=never

RUN --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --no-dev --no-install-project

FROM python:3.12-slim

ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONPATH="/app" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

RUN useradd -u 1000 -m -s /bin/bash -U app && \
    mkdir -p /app /opt/venv && \
    chown -R app:app /app /opt/venv

COPY --from=builder --chown=app:app /opt/venv /opt/venv

USER app
WORKDIR /app

COPY --chown=app:app . /app

EXPOSE 8000

ENTRYPOINT ["uvicorn", "cc_simple_server.server:app"]
CMD ["--host", "0.0.0.0", "--port", "8000"]

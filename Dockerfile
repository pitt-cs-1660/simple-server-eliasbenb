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
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR /app

COPY . /app
COPY --from=builder /opt/venv /opt/venv

EXPOSE 8000

ENTRYPOINT ["/opt/venv/bin/python", "-m", "uvicorn", "cc_simple_server.server:app"]
CMD ["--host", "0.0.0.0", "--port", "8000"]

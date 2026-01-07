# syntax=docker/dockerfile:1.6
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy only dependency metadata first (better caching)
COPY pyproject.toml uv.lock ./

# Recommended when using a cache mount
ENV UV_LINK_MODE=copy

# Install deps only (fast rebuilds when code changes)
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked --no-install-project

# Now copy the rest
COPY src/ src/
COPY data/ data/
COPY README.md README.md

# Install the project itself (optional but common)
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked

ENTRYPOINT ["uv", "run", "--locked", "src/finalexcercise/train.py"]

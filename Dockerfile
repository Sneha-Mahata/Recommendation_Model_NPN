# Dockerfile (use this)
FROM python:3.10-slim

# Avoid interactive prompts during apt installs
ENV DEBIAN_FRONTEND=noninteractive

# Install system build deps needed by scipy / scikit-surprise etc.
RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential \
      git \
      curl \
      ca-certificates \
      pkg-config \
      python3-dev \
      gfortran \
      libopenblas-dev \
      liblapack-dev \
      libblas-dev \
      && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements first to leverage layer caching
COPY requirements.txt .

# Upgrade pip & install helpful build tools
RUN pip install --upgrade pip setuptools wheel cython

# Install python libs
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source
COPY . /app

EXPOSE 8000

CMD ["gunicorn", "-k", "uvicorn.workers.UvicornWorker", "app:app", "-b", "0.0.0.0:8000", "--workers", "1"]

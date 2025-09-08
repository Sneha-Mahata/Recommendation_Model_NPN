# Dockerfile
FROM python:3.10-slim

# Install system build deps needed by scipy / scikit-surprise etc.
RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential \
      git \
      curl \
      python3-dev \
      gfortran \
      libopenblas-dev \
      liblapack-dev \
      libatlas-base-dev \
      && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .

# upgrade pip + tools helpful for build
RUN pip install --upgrade pip setuptools wheel cython

# install python deps
RUN pip install --no-cache-dir -r requirements.txt

# copy source
COPY . /app

EXPOSE 8000

CMD ["gunicorn", "-k", "uvicorn.workers.UvicornWorker", "app:app", "-b", "0.0.0.0:8000", "--workers", "1"]

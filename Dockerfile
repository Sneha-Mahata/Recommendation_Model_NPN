# Dockerfile
FROM python:3.11-slim

# install build deps for surprise
RUN apt-get update && apt-get install -y build-essential curl git libopenblas-dev gcc g++ && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# copy app
COPY . /app

# expose port
EXPOSE 8000

# start uvicorn
CMD ["gunicorn", "-k", "uvicorn.workers.UvicornWorker", "app:app", "-b", "0.0.0.0:8000", "--workers", "1"]

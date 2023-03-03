# Builder stage
FROM python:3.9-slim-bullseye AS builder

# Install build tools and dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential libfreetype6-dev \
    && rm -rf /var/lib/apt/lists/*

# Install and build the necessary packages
COPY requirements.txt ./
RUN pip wheel --no-cache-dir -w wheels -r requirements.txt

# Runner stage
# FROM python:3.9-slim-bullseye
FROM balenalib/raspberrypi4-64-debian-python:3.9-bullseye
# Copy the compiled packages from the builder stage
COPY --from=builder /wheels /wheels
# Copy files from host
COPY requirements.txt oled ./
COPY fonts ./usr/share/fonts
RUN addgroup -gid 997 gpio && usermod -a -G gpio root
# Install the packages
RUN apt-get update \
    && apt-get install -y docker.io\
    && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir --no-index --find-links=/wheels -r requirements.txt \
    && rm -rf wheels

ENTRYPOINT ["python3", "oled"]

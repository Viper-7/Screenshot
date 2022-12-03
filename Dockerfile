# Use Ubuntu 20.04 as the base image
FROM ubuntu:20.04

RUN DEBIAN_FRONTEND=noninteractive
ENV TZ=Australia/Sydney
run apt-get update
RUN apt-get install -y tzdata

# Install Python, pip, and the necessary packages to build Python packages
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    build-essential \
    libffi-dev \
    libssl-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install the latest versions of Selenium, Flask, Gunicorn, and PhantomJS using pip
RUN pip3 install selenium==3.8.0 flask gunicorn 

# install google chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
RUN apt-get -y update
RUN apt-get install -y google-chrome-stable

# install chromedriver
RUN apt-get install -yqq unzip curl
RUN wget -O /tmp/chromedriver.zip http://chromedriver.storage.googleapis.com/`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE`/chromedriver_linux64.zip
RUN unzip /tmp/chromedriver.zip chromedriver -d /usr/local/bin/

# set display port to avoid crash
ENV DISPLAY=:99

COPY ./app/ /app

WORKDIR /app

CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]


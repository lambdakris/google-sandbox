FROM python:3.10-slim

ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

WORKDIR /home/app

COPY requirements.txt .

RUN pip install -r requirements.txt --no-cache-dir --upgrade

COPY . .

CMD [ "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080" ]
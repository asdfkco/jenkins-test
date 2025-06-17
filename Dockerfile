FROM python:3.11-slim

WORKDIR /tmp

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY ./main.py ./app/main.py

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]

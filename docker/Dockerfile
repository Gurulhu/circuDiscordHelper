FROM python:slim

WORKDIR /opt/lobotomist/

COPY lobotomist.py lobotomist.py
COPY requirements.txt requirements.txt

RUN pip install -r requirements.txt

CMD ["python", "/opt/lobotomist/lobotomist.py", "$DISCORD_TOKEN"]

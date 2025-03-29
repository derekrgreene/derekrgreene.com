FROM python:3.9-slim
WORKDIR /app
COPY . /app
RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 8050
CMD /bin/bash -c "python domains.py & python websocket.py & flask run --host=0.0.0.0 --port=8050"
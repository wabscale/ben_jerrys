FROM alpine

ENV CERTPATH=default
ENV SITENAME=default
ENV WORKERS=8
ENV PORT=5000

RUN apk --update add python3

COPY requirements.txt /flasq/
WORKDIR /flasq
RUN pip3 install -r requirements.txt
RUN rm requirements.txt

RUN mkdir -p /etc/letsencrypt
RUN mkdir -p /flasq/web/data

CMD gunicorn --config gunicorn_config.py web:app

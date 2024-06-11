FROM python:alpine3.19

RUN mkdir /usr/src/FlaskApp

COPY . /FlaskApp/

COPY requirements.txt usr/src/FlaskApp

WORKDIR /FlaskApp

COPY website /FlaskApp/

COPY main.py /FlaskApp/

RUN pip install -r requirements.txt

EXPOSE 8080

CMD [ "python3", "main.py" ]
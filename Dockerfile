FROM python:alpine3.7
COPY . /app
WORKDIR /app
RUN pip install flask
EXPOSE 80
ENV MY_NAME SAIKUMAR
ENTRYPOINT [ "python" ]
CMD [ "app.py" ]

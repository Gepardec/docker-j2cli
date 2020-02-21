FROM python:3

RUN pip3 install j2cli j2cli[yaml] --upgrade 
WORKDIR /mnt

CMD [ "j2" ]
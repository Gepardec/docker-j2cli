FROM python:3

RUN pip3 install j2cli j2cli[yaml] pyyaml pybase64 --upgrade 
COPY jinja-filter/ /opt/jinja/filters/
WORKDIR /mnt

CMD [ "j2" ]
FROM ubuntu:20.04


# Installing awscli to use in load env script
# Installing curl, needed for container health checks
RUN  apt-get update \
     && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
     python3-pip apache2 php

RUN pip3 install ssm-parameter-store
COPY ./docker-entrypoint.sh /bin/
RUN chmod 755 /bin/docker-entrypoint.sh
COPY load-ssm-parameters.py /bin
COPY index.php /var/www/html/index.php
#COPY environment-variables.go /bin


EXPOSE 80

ENTRYPOINT ["/bin/docker-entrypoint.sh"]
CMD ["apachectl", "-D","FOREGROUND"]

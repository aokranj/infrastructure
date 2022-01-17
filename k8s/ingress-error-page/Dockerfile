### Base to start with
#
FROM ubuntu:20.04



### Prevent APT from asking any questions
#
ARG DEBIAN_FRONTEND=noninteractive



### Install UTF-8 locale
#
RUN apt-get update && \
    apt-get install -y locales && \
    rm -rf /var/lib/apt/lists/*

RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8



### Install Apache + PHP (+ modules for both)
#
RUN apt-get update \
    && \
    apt-get install -y \
        apache2 \
    && \
    rm -rf /var/lib/apt/lists/*



### Manage configuration files and error page content
#
RUN     a2dissite       000-default.conf

ADD     apache2-conf/ingress-error-page.conf    /etc/apache2/sites-enabled/ingress-error-page.conf
ADD     error-page-content                      /data/ingress-error-page/public

RUN     mkdir -p /run/apache2



### Expose TCP port 80
#
EXPOSE 80



### Command to start in the container
#
# ENVs are here to replace apachectl with apache2, since apachectl does not handle SIGINT.
# (Not handling SIGINT causes stalls with container shutdowns.)
#
ENV APACHE_RUN_DIR=/var/run/apache2
ENV APACHE_LOCK_DIR=/var/lock/apache2
ENV APACHE_PID_FILE=/var/run/apache2/apache2.pid
ENV APACHE_RUN_USER=www-data
ENV APACHE_RUN_GROUP=www-data
ENV APACHE_LOG_DIR=/var/log/apache2

CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]

FROM postgres:9.3.9

MAINTAINER Daniel Caldwell "daniel@danielcaldwell.com"

LABEL description="Docker file for creating the postgres database that will store our database data"

RUN mkdir --parents /var/lib/postgresql/data
RUN chown postgres:postgres /var/lib/postgresql/data
RUN chown postgres:postgres /var/lib/postgresql

VOLUME /var/lib/postgresql/data


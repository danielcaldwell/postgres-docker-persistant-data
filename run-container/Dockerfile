FROM postgres:9.3.9

MAINTAINER Daniel Caldwell "daniel@danielcaldwell.com"

LABEL description="Docker file for creating the postgres database that will store our test database"

ENV LANG en_US.utf8

COPY ./config/initdb.sh /docker-entrypoint-initdb.d/initdb.sh


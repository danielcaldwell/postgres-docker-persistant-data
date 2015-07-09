# Postgres Docker Persistent Data


This is an demo project showing how to persist data using docker containers when working with the postgres docker container. 

---
## Build and run the data container

When persisting data using docker containers, it is best to create a data-container, which is responsible for maintaining the volumes for the data as well as a running container, which is responsible for running the server. The running server's container can be killed, removed, restarted as needed, but the data container just needs to exist. The powers that be are working hard to provide better support for volumes when Docker 1.8.0 comes out. When that happens these things may change. 


First pull the project from github.
Then build the data container and run it to create it. It doesn't need to run to hold the volume, just exist. That is why it running a simple 'ls' before it exits.

```
dcaldwel@dcaldwelhome:~/Documents/Projects/docker/postgres-docker-persistant-data$ cd data-container/
dcaldwel@dcaldwelhome:~/Documents/Projects/docker/postgres-docker-persistant-data/data-container$ ./build_docker.sh 
Sending build context to Docker daemon  5.12 kB
Sending build context to Docker daemon 
Step 0 : FROM postgres:9.3.9
 ---> 5aa37a703a94
Step 1 : MAINTAINER Daniel Caldwell "daniel@danielcaldwell.com"
 ---> Running in d7cbc64a30e0
 ---> 06530f34047f
Removing intermediate container d7cbc64a30e0
Step 2 : LABEL description "Docker file for creating the postgres database that will store our database data"
 ---> Running in e03d91fc3683
 ---> 67055d87fb99
Removing intermediate container e03d91fc3683
Step 3 : RUN mkdir --parents /var/lib/postgresql/data
 ---> Running in 2fce13ac4922
 ---> 234ef011847f
Removing intermediate container 2fce13ac4922
Step 4 : RUN chown postgres:postgres /var/lib/postgresql/data
 ---> Running in 49f7c319be2b
 ---> 4e23dc226309
Removing intermediate container 49f7c319be2b
Step 5 : RUN chown postgres:postgres /var/lib/postgresql
 ---> Running in beb96527d330
 ---> cb49f0009b20
Removing intermediate container beb96527d330
Step 6 : VOLUME /var/lib/postgresql/data
 ---> Running in 7c24b07c2877
 ---> 6f3be1eb1bda
Removing intermediate container 7c24b07c2877
Successfully built 6f3be1eb1bda
dcaldwel@dcaldwelhome:~/Documents/Projects/docker/postgres-docker-persistant-data/data-container$ ./run_docker.sh 
bin
boot
dev
docker-entrypoint-initdb.d
docker-entrypoint.sh
etc
home
lib
lib64
media
mnt
opt
proc
root
run
sbin
selinux
srv
sys
tmp
usr
var
dcaldwel@dcaldwelhome:~/Documents/Projects/docker/postgres-docker-persistant-data/data-container$ docker ps -a
CONTAINER ID        IMAGE                   COMMAND                CREATED             STATUS                         PORTS               NAMES
0bdfa8e04964        ac_postgres_test_data   "/docker-entrypoint.   13 seconds ago      Exited (0) 12 seconds ago                          ac_postgres_test_data  
```


## Build and run the run container

```
dcaldwel@dcaldwelhome:~/Documents/Projects/docker/postgres-docker-persistant-data/run-container$ ./build_docker.sh 
Sending build context to Docker daemon 6.656 kB
Sending build context to Docker daemon 
Step 0 : FROM postgres:9.3.9
 ---> 5aa37a703a94
Step 1 : MAINTAINER Daniel Caldwell "daniel@danielcaldwell.com"
 ---> Using cache
 ---> 06530f34047f
Step 2 : LABEL description "Docker file for creating the postgres database that will store our test database"
 ---> Running in f78234e72b02
 ---> 2f5e6d52d492
Removing intermediate container f78234e72b02
Step 3 : ENV LANG en_US.utf8
 ---> Running in 550bc2a60562
 ---> 74ed6445d6fe
Removing intermediate container 550bc2a60562
Step 4 : COPY ./config/initdb.sh /docker-entrypoint-initdb.d/initdb.sh
 ---> 5f6386be4e89
Removing intermediate container cea72974369d
Successfully built 5f6386be4e89
dcaldwel@dcaldwelhome:~/Documents/Projects/docker/postgres-docker-persistant-data/run-container$ ./run_docker.sh 
136b42fd7dfa79e380ed5d50aeba79c2004a7e8b40db6302a91798c8171455f7
dcaldwel@dcaldwelhome:~/Documents/Projects/docker/postgres-docker-persistant-data/run-container$ docker ps
CONTAINER ID        IMAGE               COMMAND                CREATED             STATUS              PORTS               NAMES
136b42fd7dfa        ac_postgres_test    "/docker-entrypoint.   2 seconds ago       Up 2 seconds        5432/tcp            ac_postgres_test  
```

## Connect to the running container and create a database

Use another temporary container to connect to the running container. That way it can be tested without having postgres' client installed on the host machine. Create another database so we can show how it persists. 


```
dcaldwel@dcaldwelhome:~/Documents/Projects/docker/postgres-docker-persistant-data/run-container$ 
dcaldwel@dcaldwelhome:~/Documents/Projects/docker/postgres-docker-persistant-data/run-container$ docker run --rm -t -i --link ac_postgres_test postgres:9.3 /bin/bash
root@3d483796b2e0:/# gosu postgres -p 5432 -h ac_postgres_test
error: exec: "-p": executable file not found in $PATH
root@3d483796b2e0:/# gosu postgres psql -p 5432 -h ac_postgres_test
psql (9.3.9)
Type "help" for help.

postgres=# \list
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 testme    | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
(4 rows)

postgres=# create database iampersistenttoo;
CREATE DATABASE
postgres=# \list
                                    List of databases
       Name       |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
------------------+----------+----------+------------+------------+-----------------------
 iampersistenttoo | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 postgres         | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0        | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
                  |          |          |            |            | postgres=CTc/postgres
 template1        | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
                  |          |          |            |            | postgres=CTc/postgres
 testme           | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
(5 rows)

postgres=# \q
could not save history to file "/home/postgres/.psql_history": Operation not permitted
root@3d483796b2e0:/# exit
exit
dcaldwel@dcaldwelhome:~/Documents/Projects/docker/postgres-docker-persistant-data/run-container$ 




## kill and rerun the running container

Now that a change was made to the data, it's time to kill the running container and restart. Using the scripts to do this makes it easier, just to make sure the names and tags are always set right. 

```
dcaldwel@dcaldwelhome:~/Documents/Projects/docker/postgres-docker-persistant-data/run-container$ ./kill_docker.sh 
ac_postgres_test
ac_postgres_test
dcaldwel@dcaldwelhome:~/Documents/Projects/docker/postgres-docker-persistant-data/run-container$ ./run_docker.sh 
313afc167a1544e0d0cba9ccfeb8bc282548e4b7440e5d8870d9a5ee1276bf29
dcaldwel@dcaldwelhome:~/Documents/Projects/docker/postgres-docker-persistant-data/run-container$ docker ps 
CONTAINER ID        IMAGE               COMMAND                CREATED             STATUS              PORTS               NAMES
313afc167a15        ac_postgres_test    "/docker-entrypoint.   6 seconds ago       Up 5 seconds        5432/tcp            ac_postgres_test   
```

## check for the database we created before

After the container has been restarted, run the temporary container again to see the persisted data

```
dcaldwel@dcaldwelhome:~/Documents/Projects/docker/postgres-docker-persistant-data/run-container$ docker run --rm -t -i --link ac_postgres_test postgres:9.3 /bin/bash
root@310dcb15d4fa:/# gosu postgres psql -p 5432 -h ac_postgres_test
psql (9.3.9)
Type "help" for help.

postgres=# \list
                                    List of databases
       Name       |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
------------------+----------+----------+------------+------------+-----------------------
 iampersistenttoo | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 postgres         | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0        | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
                  |          |          |            |            | postgres=CTc/postgres
 template1        | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
                  |          |          |            |            | postgres=CTc/postgres
 testme           | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
(5 rows)

postgres=# \q
could not save history to file "/home/postgres/.psql_history": Operation not permitted
root@310dcb15d4fa:/# exit
exit
dcaldwel@dcaldwelhome:~/Documents/Projects/docker/postgres-docker-persistant-data/run-container$ 
```

That is how to persist data and work with containers to access that data. If you need to back it up, just launch a temporary container to do a pg_dump, then rsync the dump or sftp it to a backup server somewhere. The key here is that there is persistent data without tying it to a host. Thus it can be hosted in a cluster swarm.





#  Connect to the django cluster and create a user 
gosu postgres postgres --single -jE << EOF
create user testuser;
alter user testuser with superuser;
alter user testuser with createdb; 
alter user testuser with createrole;
alter user testuser with password 'test';
EOF

# then create a database
# this is necessary so that connections through psycopg do not fail;
gosu postgres postgres --single -jE << EOF
create database testme; 
EOF


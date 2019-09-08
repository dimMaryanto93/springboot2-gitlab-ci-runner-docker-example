create table users(
    id character varying (64) not null primary key,
    username character varying (100) not null unique ,
    password character varying (100)
);

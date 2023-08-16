create table if not exists actor
(
    actor_id    integer    not null
        primary key,
    first_name  varchar(45)                                               not null,
    last_name   varchar(45)                                               not null,
    last_update timestamp default now()                                   not null
);


create index if not exists idx_actor_last_name
    on actor (last_name);


create table if not exists category
(
    category_id integer   not null
        primary key,
    name        varchar(25)                                                     not null,
    last_update timestamp default now()                                         not null
);

create table if not exists country
(
    country_id  integer   not null
        primary key,
    country     varchar(50)                                                   not null,
    last_update timestamp default now()                                       not null
);

create table if not exists city
(
    city_id     integer    not null
        primary key,
    city        varchar(50)                                             not null,
    country_id  smallint                                                not null
        constraint fk_city
            references country,
    last_update timestamp default now()                                 not null
);


create table if not exists address
(
    address_id  integer   not null
        primary key,
    address     varchar(50)                                                   not null,
    address2    varchar(50),
    district    varchar(20)                                                   not null,
    city_id     smallint                                                      not null
        constraint fk_address_city
            references city,
    postal_code varchar(10),
    phone       varchar(20)                                                   not null,
    last_update timestamp default now()                                       not null
);


create table if not exists customer
(
    customer_id integer   not null
        primary key,
    store_id    smallint                                                        not null,
    first_name  varchar(45)                                                     not null,
    last_name   varchar(45)                                                     not null,
    email       varchar(50),
    address_id  smallint                                                        not null
        references address
            on update cascade on delete restrict,
    activebool  boolean   default true                                          not null,
    create_date date      default ('now'::text)::date                           not null,
    last_update timestamp default now(),
    active      integer
);


create index if not exists idx_fk_address_id
    on customer (address_id);

create index if not exists idx_fk_store_id
    on customer (store_id);

create index if not exists idx_last_name
    on customer (last_name);


create index if not exists idx_fk_city_id
    on address (city_id);


create index if not exists idx_fk_country_id
    on city (country_id);


create table if not exists language
(
    language_id integer    not null
        primary key,
    name        char(20)                                                        not null,
    last_update timestamp default now()                                         not null
);



create table if not exists film
(
    film_id          integer        not null
        primary key,
    title            varchar(255)                                                not null,
    description      text,
    release_year     year,
    language_id      smallint                                                    not null
        references language
            on update cascade on delete restrict,
    rental_duration  smallint      default 3                                     not null,
    rental_rate      numeric(4, 2) default 4.99                                  not null,
    length           smallint,
    replacement_cost numeric(5, 2) default 19.99                                 not null,
    rating           mpaa_rating   default 'G'::mpaa_rating,
    last_update      timestamp     default now()                                 not null,
    special_features text[],
    fulltext         tsvector                                                    not null
);

create index if not exists film_fulltext_idx
    on film using gist (fulltext);

create index if not exists idx_fk_language_id
    on film (language_id);

create index if not exists idx_title
    on film (title);

create trigger film_fulltext_trigger
    before insert or update
    on film
    for each row
execute procedure pg_catalog.tsvector_update_trigger('fulltext', 'pg_catalog.english', 'title', 'description');


create table if not exists film_actor
(
    actor_id    smallint                not null
        references actor
            on update cascade on delete restrict,
    film_id     smallint                not null
        references film
            on update cascade on delete restrict,
    last_update timestamp default now() not null,
    primary key (actor_id, film_id)
);



create index if not exists idx_fk_film_id
    on film_actor (film_id);


create table if not exists film_category
(
    film_id     smallint                not null
        references film
            on update cascade on delete restrict,
    category_id smallint                not null
        references category
            on update cascade on delete restrict,
    last_update timestamp default now() not null,
    primary key (film_id, category_id)
);


create table if not exists inventory
(
    inventory_id integer    not null
        primary key,
    film_id      smallint                                                          not null
        references film
            on update cascade on delete restrict,
    store_id     smallint                                                          not null,
    last_update  timestamp default now()                                           not null
);



create index if not exists idx_store_id_film_id
    on inventory (store_id, film_id);


create table if not exists staff
(
    staff_id    integer   not null
        primary key,
    first_name  varchar(45)                                               not null,
    last_name   varchar(45)                                               not null,
    address_id  smallint                                                  not null
        references address
            on update cascade on delete restrict,
    email       varchar(50),
    store_id    smallint                                                  not null,
    active      boolean   default true                                    not null,
    username    varchar(16)                                               not null,
    password    varchar(40),
    last_update timestamp default now()                                   not null,
    picture     bytea
);


create table if not exists rental
(
    rental_id    integer    not null
        primary key,
    rental_date  timestamp                                                   not null,
    inventory_id integer                                                     not null
        references inventory
            on update cascade on delete restrict,
    customer_id  smallint                                                    not null
        references customer
            on update cascade on delete restrict,
    return_date  timestamp,
    staff_id     smallint                                                    not null
        constraint rental_staff_id_key
            references staff,
    last_update  timestamp default now()                                     not null
);



create table if not exists payment
(
    payment_id   integer  not null
        primary key,
    customer_id  smallint                                                    not null
        references customer
            on update cascade on delete restrict,
    staff_id     smallint                                                    not null
        references staff
            on update cascade on delete restrict,
    rental_id    integer                                                     not null
        references rental
            on update cascade on delete set null,
    amount       numeric(5, 2)                                               not null,
    payment_date timestamp                                                   not null
);



create index if not exists idx_fk_customer_id
    on payment (customer_id);

create index if not exists idx_fk_rental_id
    on payment (rental_id);

create index if not exists idx_fk_staff_id
    on payment (staff_id);

create index if not exists idx_fk_inventory_id
    on rental (inventory_id);

create unique index if not exists idx_unq_rental_rental_date_inventory_id_customer_id
    on rental (rental_date, inventory_id, customer_id);


create table if not exists store
(
    store_id         integer   not null
        primary key,
    manager_staff_id smallint                                                  not null
        references staff
            on update cascade on delete restrict,
    address_id       smallint                                                  not null
        references address
            on update cascade on delete restrict,
    last_update      timestamp default now()                                   not null
);


create unique index if not exists idx_unq_manager_staff_id
    on store (manager_staff_id);



create type mpaa_rating as enum ('G', 'PG', 'PG-13', 'R', 'NC-17');

create domain year as integer
    constraint year_check check ((VALUE >= 1901) AND (VALUE <= 2155));

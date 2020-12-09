
-- PostgreSQL 12.4
CREATE TABLE IF NOT EXISTS discounts
(
    discount_id serial primary key,
    discount_name varchar(255) NOT NULL,
    percent numeric(5,2),
    CONSTRAINT ch_percent CHECK ( percent BETWEEN 0 AND 100)
);
CREATE TABLE  IF NOT EXISTS  discounts_tickets(
    discount_ticket_id serial primary key,
    discount_id int NOT NULL ,
    ticket_id int NOT NULL
);
CREATE TABLE IF NOT EXISTS passengers(
    passenger_id serial primary key,
    account_id int,
    passenger_last_name varchar(255) NOT NULL,
    passenger_first_name varchar(255) NOT NULL,
    passenger_middle_name varchar(255) NOT NULL,
    gender boolean NOT NULL,
    birthday date NOT NULL,
    passport_series char(2),
    passport_num numeric(9) NOT NULL,
    individual_tax_num char(10) UNIQUE,
    UNIQUE (passport_series, passport_num),
    CONSTRAINT ch_name
        CHECK ( passenger_last_name ~ '^\D+$'
                    AND passenger_first_name ~ '^\D+$'
                    AND passenger_middle_name ~ '^\D+$'),
    CONSTRAINT ch_birthday CHECK ( birthday > '1900-01-01' )
);
CREATE TABLE IF NOT EXISTS accounts(
    account_id serial primary key,
    login varchar(60) UNIQUE NOT NULL,
    email varchar(255) NOT NULL,
    password varchar(60) NOT NULL,
    bonus_score numeric(6,2) NOT NULL DEFAULT 0,
    CONSTRAINT ch_email CHECK ( email ~ '^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$'),
    CONSTRAINT ch_not_negative CHECK ( bonus_score>=0 )
);
CREATE TABLE IF NOT EXISTS stations(
    station_id serial primary key,
    station_name varchar(255) NOT NULL,
    country varchar(255) UNIQUE,
    local_time smallint
);
CREATE TABLE IF NOT EXISTS trains(
    train_id serial primary key,
    locomotive_id int NOT NULL,
    train_num int NOT NULL UNIQUE,
    CONSTRAINT ch_not_negative CHECK ( train_num>=0)
);
CREATE TABLE IF NOT EXISTS routes_trains(
    route_train_id serial primary key,
    route_id int NOT NULL,
    train_id int NOT NULL,
    route_status boolean NOT NULL DEFAULT TRUE,
    route_date date NOT NULL,
    delay int,
    CONSTRAINT ch_flight_date CHECK ( route_date > '1900-01-01' )
);
CREATE TABLE IF NOT EXISTS routes_stations(
    route_station_id serial primary key,
    route_id int NOT NULL ,
    station_id int NOT NULL ,
    arrival_time time ,
    departure_time time ,
    platform smallint NOT NULL DEFAULT 1,
    distance numeric(6,1) NOT NULL,
    CONSTRAINT ch_positive CHECK ( platform >0),
    CONSTRAINT ch_not_negative CHECK ( distance>=0)
);
CREATE TABLE IF NOT EXISTS routes(
    route_id serial primary key ,
    route_num int NOT NULL UNIQUE,
    CONSTRAINT ch_not_negative CHECK ( route_num>=0)
);
CREATE TABLE IF NOT EXISTS wagons_in_train(
    wagon_in_train_id serial primary key ,
    train_id int NOT NULL ,
    wagon_id int NOT NULL ,
    wagon_train_num smallint NOT NULL
    CONSTRAINT ch_not_negative CHECK (wagon_train_num >=0)
);
CREATE TABLE IF NOT EXISTS wagons(
    wagon_id serial primary key,
    wagon_model_id int NOT NULL,
    wagon_serial_num int NOT NULL UNIQUE,
    production_year smallint NOT NULL,
    modernization_year smallint,
    CONSTRAINT ch_not_negative CHECK ( wagon_serial_num>=0 ),
    CONSTRAINT ch_year_wagon CHECK ( production_year>=1825 AND  modernization_year>=1825 )
);
CREATE TABLE IF NOT EXISTS services(
    service_id serial primary key,
    service_name varchar(255) NOT NULL ,
    price numeric(7,2)
);
CREATE TABLE IF NOT EXISTS services_tickets(
    service_ticket_id serial primary key ,
    service_id int NOT NULL ,
    ticket_id int NOT NULL ,
    quantity int NOT NULL DEFAULT 1,
    CONSTRAINT ch_not_negative CHECK ( quantity >0 )
);
CREATE TABLE IF NOT EXISTS tickets(
    ticket_id serial primary key ,
    passenger_id int NOT NULL ,
    route_train_id int NOT NULL ,
    wagon_in_train_id int NOT NULL ,
    departure_station int,
    arrival_station int,
    ticket_num int NOT NULL UNIQUE ,
    place_num smallint NOT NULL,
    price numeric(7,2) NOT NULL DEFAULT 0,
    paid_bonuses numeric(5,2),
    accrued_bonuses numeric(5,2),
    CONSTRAINT ch_positive CHECK ( ticket_num >0 AND place_num >0 ),
    CONSTRAINT ch_not_negative CHECK ( price >=0 AND paid_bonuses >=0 AND accrued_bonuses >=0)
);
CREATE TABLE IF NOT EXISTS wagon_types(
    wagon_type_id serial primary key ,
    seat_type boolean NOT NULL ,
    wagon_type_name varchar (60) NOT NULL UNIQUE,
    seat_quantity smallint NOT NULL DEFAULT 0,
    CONSTRAINT ch_not_negative CHECK ( seat_quantity>=0 )
);
CREATE TABLE IF NOT EXISTS wagon_models(
    wagon_model_id serial primary key ,
    wagon_type_id int,
    wagon_model_name varchar(60) NOT NULL UNIQUE,
    price_k numeric(8,4) NOT NULL,
    CONSTRAINT ch_not_negative CHECK ( price_k>=0 )
);
CREATE TABLE IF NOT EXISTS locomotives(
    locomotive_id serial primary key ,
    locomotive_type_id int NOT NULL ,
    locomotive_num int NOT NULL UNIQUE ,
    CONSTRAINT ch_positive CHECK (locomotive_num>0)
);
CREATE TABLE IF NOT EXISTS locomotive_types(
    locomotive_type_id serial primary key ,
    locomotive_type_name varchar(60) NOT NULL UNIQUE,
    fuel_id int NOT NULL
);
CREATE TABLE IF NOT EXISTS fuels(
    fuel_id serial primary key,
    fuel_name varchar(60) NOT NULL UNIQUE
);

CREATE INDEX tickets$passenger_id_idx ON tickets (passenger_id);
CREATE INDEX tickets$route_train_id_idx ON tickets (route_train_id);
CREATE INDEX tickets$wagon_in_train_id_idx ON tickets (wagon_in_train_id);
CREATE INDEX tickets$arrival_station_id_idx ON tickets (arrival_station);
CREATE INDEX tickets$departure_station_id_idx ON tickets (departure_station);
CREATE INDEX passengers$account_id_idx ON passengers (account_id);
CREATE INDEX routes_stations$route_id_idx ON routes_stations (route_id);
CREATE INDEX routes_stations$station_id_idx ON routes_stations (station_id);
CREATE INDEX routes_trains$route_id_idx ON routes_trains (route_id);
CREATE INDEX routes_trains$train_id_idx ON routes_trains (train_id);
CREATE INDEX trains$locomotive_id_idx ON trains (locomotive_id);
CREATE INDEX wagons$wagon_model_id_idx ON wagons (wagon_model_id);
CREATE INDEX wagon_models$wagon_type_id_idx ON wagon_models (wagon_type_id);
CREATE INDEX wagons_in_train$train_id_idx ON wagons_in_train (train_id);
CREATE INDEX wagons_in_train$wagon_id_idx ON wagons_in_train (wagon_id);
CREATE INDEX discounts_tickets$discount_id_idx ON discounts_tickets (discount_id);
CREATE INDEX discounts_tickets$tickets_id_idx ON discounts_tickets (ticket_id);
CREATE INDEX services_tickets$service_id_idx ON services_tickets (service_id);
CREATE INDEX services_tickets$tickets_id_idx ON services_tickets (ticket_id);
CREATE INDEX locomotives$locomotive_type_id_idx ON locomotives (locomotive_type_id);
CREATE INDEX locomotive_types$fuel_id_idx ON locomotive_types (fuel_id);

ALTER TABLE tickets
    ADD CONSTRAINT fk_tickets$passenger_id
        FOREIGN KEY (passenger_id)
            REFERENCES passengers (passenger_id) ON UPDATE CASCADE ON DELETE CASCADE,
    ADD CONSTRAINT fk_tickets$route_train_id
        FOREIGN KEY (route_train_id)
            REFERENCES routes_trains (route_train_id) ON UPDATE CASCADE ON DELETE CASCADE ,
    ADD CONSTRAINT fk_tickets$wagon_in_train_id
        FOREIGN KEY (wagon_in_train_id)
            REFERENCES  wagons_in_train (wagon_in_train_id) ON UPDATE CASCADE ON DELETE CASCADE,
    ADD CONSTRAINT fk_tickets$arrival_station_id
        FOREIGN KEY (arrival_station)
            REFERENCES stations (station_id) ON UPDATE CASCADE ON DELETE CASCADE,
    ADD CONSTRAINT fk_tickets$departure_station_id
        FOREIGN KEY (departure_station)
            REFERENCES stations (station_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE passengers
    ADD CONSTRAINT fk_passengers$account_id
        FOREIGN KEY (account_id)
            REFERENCES accounts (account_id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE routes_stations
    ADD CONSTRAINT fk_routes_stations$route_id
        FOREIGN KEY (station_id)
            REFERENCES stations (station_id) ON UPDATE CASCADE ON DELETE CASCADE,
    ADD CONSTRAINT fk_routes_stations$station_id
        FOREIGN KEY (route_id)
            REFERENCES routes (route_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE routes_trains
    ADD CONSTRAINT fk_routes_trains$route_id
        FOREIGN KEY (route_id)
            REFERENCES routes (route_id) ON UPDATE CASCADE ON DELETE CASCADE,
    ADD CONSTRAINT fk_routes_trains$train_id
        FOREIGN KEY (train_id) REFERENCES trains (train_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE trains
    ADD CONSTRAINT fk_trains$locomotive_id
        FOREIGN KEY (locomotive_id)
            REFERENCES locomotives (locomotive_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE wagons
    ADD CONSTRAINT fk_wagons$wagon_model_id
        FOREIGN KEY (wagon_model_id)
            REFERENCES wagon_models (wagon_model_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE wagon_models
    ADD CONSTRAINT fk_wagon_models$wagon_type_id
        FOREIGN KEY (wagon_type_id)
            REFERENCES wagon_types (wagon_type_id) ON UPDATE CASCADE ON DELETE CASCADE ;
ALTER TABLE wagons_in_train
    ADD CONSTRAINT fk_wagons_in_train$train_id
        FOREIGN KEY (train_id)
            REFERENCES trains (train_id) ON UPDATE CASCADE ON DELETE CASCADE,
    ADD CONSTRAINT fk_wagons_in_train$wagon_id
        FOREIGN KEY (wagon_id)
            REFERENCES wagons (wagon_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE discounts_tickets
    ADD CONSTRAINT fk_discounts_tickets$discount_id
        FOREIGN KEY (discount_id)
            REFERENCES discounts (discount_id) ON UPDATE CASCADE ON DELETE CASCADE,
    ADD CONSTRAINT fk_discounts_tickets$tickets_id
        FOREIGN KEY (ticket_id)
            REFERENCES tickets (ticket_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE services_tickets
    ADD CONSTRAINT fk_services_tickets$service_id
        FOREIGN KEY (service_id)
            REFERENCES services (service_id) ON UPDATE CASCADE ON DELETE CASCADE ,
    ADD CONSTRAINT fk_services_tickets$tickets_id
        FOREIGN KEY (ticket_id)
            REFERENCES tickets (ticket_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE locomotives
    ADD CONSTRAINT fk_locomotives$locomotive_type_id
        FOREIGN KEY (locomotive_type_id)
            REFERENCES locomotive_types (locomotive_type_id) ON UPDATE CASCADE ON DELETE CASCADE ;
ALTER TABLE locomotive_types
    ADD CONSTRAINT fk_locomotive_types$fuel_id
        FOREIGN KEY (fuel_id)
            REFERENCES fuels (fuel_id) ON UPDATE CASCADE ON DELETE CASCADE;
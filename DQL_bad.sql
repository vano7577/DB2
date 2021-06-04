INSERT INTO tickets (passenger_id, route_train_id, wagon_in_train_id, departure_station, arrival_station, ticket_num, place_num)
VALUES (1,3,40,NULL,3,1000260281,23);
DELETE from tickets where ticket_id = 11;


CREATE VIEW group_fuel_locomotives AS
    SELECT fuels.fuel_name, count(locomotives.locomotive_id) FROM fuels
    LEFT JOIN locomotive_types on fuels.fuel_id = locomotive_types.fuel_id
    LEFT JOIN locomotives on locomotive_types.locomotive_type_id = locomotives.locomotive_type_id
    GROUP BY 1
    ORDER BY 2 DESC;

CREATE OR REPLACE FUNCTION find_locomotives() RETURNS SETOF group_fuel_locomotives LANGUAGE SQL AS $$
SELECT * FROM group_fuel_locomotives;
    $$;

CREATE VIEW unused_services AS
    SELECT service_name FROM services WHERE NOT EXISTS(SELECT services_tickets.service_id FROM services_tickets);

CREATE OR REPLACE FUNCTION find_unused_services() RETURNS SETOF unused_services LANGUAGE SQL AS $$
SELECT * FROM unused_services;
    $$;

CREATE FUNCTION find_free_locomotives () RETURNS TABLE(locomotive_num int) LANGUAGE SQL AS $$
    SELECT locomotive_num FROM locomotives
    LEFT JOIN trains on locomotives.locomotive_id = trains.locomotive_id AND trains.locomotive_id IS NULL
    $$;
SELECT train_num FROM trains
INNER JOIN routes_trains on trains.train_id = routes_trains.train_id AND delay > 10;
DELETE FROM routes_trains
WHERE route_date BETWEEN '2020-11-21' AND '2020-11-22';

SELECT wagon_type_name, max(seat_quantity) from wagon_types GROUP BY wagon_type_name

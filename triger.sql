
-- PostgreSQL 12.4

CREATE OR REPLACE FUNCTION find_arrival_station(in in_route_train_id int, out int) AS $find$
SELECT routes_stations.station_id FROM routes
    INNER JOIN routes_stations ON routes.route_id = routes_stations.route_id AND
                                  routes_stations.departure_time IS NULL
    INNER JOIN routes_trains ON routes.route_id = routes_trains.route_id AND
                                routes_trains.route_train_id = in_route_train_id;
    $find$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION find_departure_station(in in_route_train_id int, out int) AS $find$
SELECT routes_stations.station_id FROM routes
    INNER JOIN routes_stations ON routes.route_id = routes_stations.route_id AND
                                  routes_stations.arrival_time IS NULL
    INNER JOIN routes_trains ON routes.route_id = routes_trains.route_id AND
                                routes_trains.route_train_id = in_route_train_id;
    $find$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION find_passenger_account(in in_passenger_id int, out int) AS $find$
    SELECT  passengers.account_id FROM tickets
        INNER JOIN passengers ON passengers.passenger_id = in_passenger_id;
    $find$LANGUAGE SQL;

CREATE PROCEDURE update_score(in in_account_id int, in new_accrued numeric(5,2),in new_paid numeric(5,2)) AS $body$
BEGIN
    UPDATE accounts
    SET bonus_score = bonus_score + new_accrued - new_paid
    WHERE account_id = in_account_id;
END;
    $body$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION find_route_station_id(in in_station_id int,  in in_route_id int, out int ) AS $$
    SELECT routes_stations.route_station_id
    FROM routes_stations
    WHERE routes_stations.station_id=in_station_id AND
          routes_stations.route_id=in_route_id
    $$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION count_distance (in in_departure_station_id int, in in_arrival_station_id int, in in_route_id int, out numeric(6,1)) AS $body$
    SELECT sum(routes_stations.distance) AS distance
    FROM routes_stations
    WHERE routes_stations.route_id = in_route_id AND
          routes_stations.route_station_id BETWEEN
              find_route_station_id(in_departure_station_id, in_route_id)+1 AND
              find_route_station_id(in_arrival_station_id, in_route_id);
    $body$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION find_ticket_price (in in_route_train_id int,in in_wagon_in_train_id int,
out numeric(7,2)
)  AS $body$
    SELECT
           count_distance (
        find_departure_station(routes_trains.route_train_id),
        find_arrival_station(routes_trains.route_train_id),
        routes_trains.route_id
        )* wagon_models.price_k
    FROM trains
    INNER JOIN routes_trains ON routes_trains.train_id=trains.train_id AND
                                routes_trains.route_train_id = in_route_train_id
    INNER JOIN wagons_in_train ON wagons_in_train.train_id = trains.train_id AND
                                  wagons_in_train.wagon_in_train_id = in_wagon_in_train_id
    INNER JOIN wagons ON wagons.wagon_id = wagons_in_train.wagon_id
    INNER JOIN wagon_models ON wagon_models.wagon_model_id = wagons.wagon_model_id;
    $body$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION set_price_bonus() RETURNS trigger AS $bonus$
    BEGIN
        IF ( find_ticket_price (new.route_train_id, new.wagon_in_train_id)) IS NULL
            THEN RAISE EXCEPTION 'price is NULL';
        END IF;
    new.price :=  find_ticket_price (new.route_train_id, new.wagon_in_train_id);
    IF (find_passenger_account(new.passenger_id) IS NOT NULL)
    THEN
    new.accrued_bonuses := new.price/100;
    new.paid_bonuses := (
        SELECT accounts.bonus_score
        FROM accounts
        WHERE account_id=find_passenger_account(new.passenger_id));
    CALL update_score(
        find_passenger_account(new.passenger_id),
        new.accrued_bonuses,
        new.paid_bonuses);
    END IF;
    RETURN new;
    END
    $bonus$LANGUAGE plpgsql;

CREATE TRIGGER bonus
BEFORE INSERT ON tickets
    FOR EACH ROW
    EXECUTE PROCEDURE set_price_bonus();

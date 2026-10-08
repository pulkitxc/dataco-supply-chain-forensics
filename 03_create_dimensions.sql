CREATE TABLE IF NOT EXISTS analytics.dim_customer (
    customer_id        INTEGER PRIMARY KEY,
    customer_segment   VARCHAR(50),
    customer_city      VARCHAR(100),
    customer_state     VARCHAR(100),
    customer_country   VARCHAR(100),
    customer_zipcode   VARCHAR(20),
    latitude           NUMERIC(10,6),
    longitude          NUMERIC(10,6)
);

CREATE TABLE IF NOT EXISTS analytics.dim_product (
    product_card_id      INTEGER PRIMARY KEY,
    product_name         VARCHAR(255),
    product_price        NUMERIC(10,2),
    product_status       INTEGER,
    category_id          INTEGER,
    category_name        VARCHAR(100),
    department_id        INTEGER,
    department_name      VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS analytics.dim_date (
    order_date_dateorders TIMESTAMP PRIMARY KEY,
    order_year            INTEGER,
    order_month           INTEGER,
    order_quarter         INTEGER,
    order_weekday         VARCHAR(20)
);
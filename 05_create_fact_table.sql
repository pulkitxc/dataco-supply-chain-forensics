CREATE TABLE IF NOT EXISTS analytics.fact_sales (
    order_item_id                  INTEGER PRIMARY KEY,
    order_id                       INTEGER,

    customer_id                    INTEGER,
    product_card_id                INTEGER,
    order_date_dateorders          TIMESTAMP,

    type                           VARCHAR(50),

    sales                          NUMERIC(12,2),
    order_profit_per_order         NUMERIC(12,2),
    benefit_per_order              NUMERIC(12,2),
    order_item_total               NUMERIC(12,2),
    sales_per_customer             NUMERIC(12,2),

    order_item_discount            NUMERIC(12,2),
    order_item_discount_rate       NUMERIC(8,4),
    order_item_quantity            INTEGER,
    order_item_product_price       NUMERIC(12,2),
    order_item_profit_ratio        NUMERIC(8,4),

    shipping_mode                  VARCHAR(50),
    delivery_status                VARCHAR(50),
    late_delivery_risk             INTEGER,
    days_for_shipping_real         INTEGER,
    days_for_shipment_scheduled    INTEGER,
    shipping_date_dateorders       TIMESTAMP,

    order_status                   VARCHAR(50),

    market                         VARCHAR(100),
    order_city                     VARCHAR(100),
    order_country                  VARCHAR(100),
    order_region                   VARCHAR(100),
    order_state                    VARCHAR(100),
    order_zipcode                  VARCHAR(20),

    CONSTRAINT fk_fact_customer
        FOREIGN KEY (customer_id)
        REFERENCES analytics.dim_customer(customer_id),

    CONSTRAINT fk_fact_product
        FOREIGN KEY (product_card_id)
        REFERENCES analytics.dim_product(product_card_id),

    CONSTRAINT fk_fact_order_date
        FOREIGN KEY (order_date_dateorders)
        REFERENCES analytics.dim_date(order_date_dateorders)
);
-- =============================================================
-- Commercial Performance and GMV Leakage Analysis; NEXORA COMMERCE LTD 
-- Database Creation & Data Load


DROP DATABASE IF EXISTS nexora_commerce;
CREATE DATABASE nexora_commerce
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE nexora_commerce;


-- =============================================================
-- STEP 1: CREATE ALL 9 TABLES
-- =============================================================

-- orders table

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
    order_id                        VARCHAR(32)     NOT NULL,
    customer_id                     VARCHAR(32)     NOT NULL,
    order_status                    VARCHAR(20)     NOT NULL,
    order_purchase_timestamp        DATETIME        NOT NULL,
    order_approved_at               DATETIME        NULL,       
    order_delivered_carrier_date    DATETIME        NULL,       
    order_delivered_customer_date   DATETIME        NULL,       
    order_estimated_delivery_date   DATETIME        NOT NULL,
    PRIMARY KEY (order_id)
);

-- customers table

DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
    customer_id             VARCHAR(32)     NOT NULL,
    customer_unique_id      VARCHAR(32)     NOT NULL,
    customer_zip_code_prefix VARCHAR(10)   NOT NULL,    
    customer_city           VARCHAR(100)    NOT NULL,
    customer_state          CHAR(2)         NOT NULL,
    PRIMARY KEY (customer_id)
);

-- order_items table

DROP TABLE IF EXISTS order_items;
CREATE TABLE order_items (
    order_id                VARCHAR(32)     NOT NULL,
    order_item_id           TINYINT         NOT NULL,   
    product_id              VARCHAR(32)     NOT NULL,
    seller_id               VARCHAR(32)     NOT NULL,
    shipping_limit_date     DATETIME        NOT NULL,
    price                   DECIMAL(10,2)   NOT NULL,
    freight_value           DECIMAL(10,2)   NOT NULL,
    PRIMARY KEY (order_id, order_item_id)
);

-- order_payments table

DROP TABLE IF EXISTS order_payments;
CREATE TABLE order_payments (
    order_id                VARCHAR(32)     NOT NULL,
    payment_sequential      TINYINT         NOT NULL,   
    payment_type            VARCHAR(20)     NOT NULL,   
    payment_installments    TINYINT         NOT NULL,
    payment_value           DECIMAL(10,2)   NOT NULL,
    PRIMARY KEY (order_id, payment_sequential)
);

-- order_reviews table
DROP TABLE IF EXISTS order_reviews;
CREATE TABLE order_reviews (
    review_id               VARCHAR(32)     NOT NULL,
    order_id                VARCHAR(32)     NOT NULL,
    review_score            TINYINT         NOT NULL,   -- 1 (worst) to 5 (best)
    review_comment_title    VARCHAR(255)    NULL,
    review_comment_message  TEXT            NULL,
    review_creation_date    DATETIME        NOT NULL,
    review_answer_timestamp DATETIME        NOT NULL,
    PRIMARY KEY (review_id)
);


-- products table
DROP TABLE IF EXISTS products;
CREATE TABLE products (
    product_id                  VARCHAR(32)     NOT NULL,
    product_category_name       VARCHAR(100)    NULL,       
    product_name_lenght         INT             NULL,      
    product_description_lenght  INT             NULL,
    product_photos_qty          INT             NULL,
    product_weight_g            DECIMAL(10,2)   NULL,
    product_length_cm           DECIMAL(10,2)   NULL,
    product_height_cm           DECIMAL(10,2)   NULL,
    product_width_cm            DECIMAL(10,2)   NULL,
    PRIMARY KEY (product_id)
);


-- sellers table

DROP TABLE IF EXISTS sellers;
CREATE TABLE sellers (
    seller_id               VARCHAR(32)     NOT NULL,
    seller_zip_code_prefix  VARCHAR(10)     NOT NULL,
    seller_city             VARCHAR(100)    NOT NULL,
    seller_state            CHAR(2)         NOT NULL,
    PRIMARY KEY (seller_id)
);


-- geolocation table 
DROP TABLE IF EXISTS geolocation;
CREATE TABLE geolocation (
    geolocation_zip_code_prefix VARCHAR(10)     NOT NULL,
    geolocation_lat             DECIMAL(18,15)  NOT NULL,
    geolocation_lng             DECIMAL(18,15)  NOT NULL,
    geolocation_city            VARCHAR(100)    NOT NULL,
    geolocation_state           CHAR(2)         NOT NULL
    -- No PRIMARY KEY
);

-- category_translation table
DROP TABLE IF EXISTS category_translation;
CREATE TABLE category_translation (
    product_category_name           VARCHAR(100)    NOT NULL,
    product_category_name_english   VARCHAR(100)    NOT NULL,
    PRIMARY KEY (product_category_name)
);


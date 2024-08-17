Create database Ecommerce_Olist;
use Ecommerce_Olist;

CReate table olist_customer_dataset(
customer_id varchar(255),
customer_unique_id varchar(255),
customer_zip_code_prefix int,
customer_city varchar(255),
customer_state char(25)
);

select * from olist_customer_dataset;

load data infile 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Data\\ecommerce_olist\\olist_customers_dataset.csv'
 into table olist_customer_dataset 
fields terminated by ','
ignore 1 lines;

create table olist_geolocation_dataset(
geolocation_zip_code_prefix varchar(255),
geolocation_lat float,
geolocation_lng float,
geolocation_city varchar(255),
geolocation_state varchar(255)
);

load data infile 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Data\\ecommerce_olist\\olist_geolocation_dataset.csv' 
into table olist_geolocation_dataset 
fields terminated by ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
ignore 1 lines;

Select * from olist_geolocation_dataset;

create table olist_orders_items_dataset(
 order_id varchar(255),
 order_item_id int,
 product_id varchar(255),
 seller_id varchar(255),
 shipping_limit_date text,
 price DECIMAL(10,2),
 freight_value DECIMAL(10,2)
 );
 
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Data\\ecommerce_olist\\olist_order_items_dataset.csv'
INTO TABLE olist_orders_items_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

create table olist_order_payment_dataset(
order_id varchar(255),
payment_sequential int,
payment_type varchar(255),
payment_installments int,
payment_value DECIMAL(10,2)
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Data\\ecommerce_olist\\olist_order_payments_dataset.csv'
INTO TABLE olist_order_payment_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

Drop table olist_order_review_dataset;
create table olist_order_review_dataset(
review_id varchar(255),
order_id varchar(255),
review_score int,
review_comment_title varchar(255),
review_comment_message varchar(255),
review_creation_date text,
review_answer_timestamp text
);
select * from olist_order_review_dataset; 

-- the problem here is when i ran the above load query i faced this error of some row was truncated, 
-- so i went into the "olist-order_review_dataset" excel file, row no. something the problem was in and
--  I replaced the review_comment_message into ".",
--  I know i shouldnt have replaced the comment but that helped me with the problem

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Data\\ecommerce_olist\\olist_order_reviews_dataset.csv'
INTO TABLE olist_order_review_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;



create table olist_orders_dataset(
order_id varchar(255),
customer_id varchar(255),
order_status varchar(25),
order_purchase_timestamp text,
order_approved_at text,
order_delivered_carrier_date text,
order_delivered_customer_date text,
order_estimated_delivery_date text
); 

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Data\\ecommerce_olist\\olist_orders_dataset.csv' 
INTO TABLE olist_orders_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

create table olist_products_dataset(
product_id varchar(255),
product_category_name varchar(255),
product_name_lenght varchar(255),
product_description_lenght varchar(255),
product_photos_qty varchar(255),
product_weight_g varchar(255),
product_length_cm varchar(255),
product_height_cm varchar(255),
product_width_cm varchar(255)
);
drop table olist_products_dataset;

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Data\\ecommerce_olist\\olist_products_dataset.csv' 
INTO TABLE olist_products_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

create table olist_sellers_dataset(
seller_id varchar(255),
seller_zip_code_prefix int,
seller_city varchar(255),
seller_state char(3)
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Data\\ecommerce_olist\\olist_sellers_dataset.csv' 
INTO TABLE olist_sellers_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

create table product_category_name_translation(
product_category_name varchar(255),
product_category_name_english varchar(255)
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Data\\ecommerce_olist\\product_category_name_translation.csv' 
INTO TABLE product_category_name_translation
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;


-- 1.Weekday Vs Weekend (order_purchase_timestamp) Payment Statistics

SELECT
    CASE
        WHEN DAYOFWEEK(STR_TO_DATE(orders.order_purchase_timestamp, '%Y-%m-%d %H:%i:%s')) IN (1, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS Day_Type,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(orders_payment.payment_value),2) AS Total_Payment,
    ROUND(AVG(orders_payment.payment_value),2) AS Average_Payment
FROM olist_orders_dataset AS orders
JOIN olist_order_payment_dataset AS orders_payment ON orders.order_id = orders_payment.order_id
GROUP BY Day_Type;

-- 2.Number of Orders with review score 5 and payment type as credit card.

select (payment_type), Round(AVG(Payment_value),2) AS  AVG_Payment_Value from olist_order_payment_dataset
Group by payment_type
ORDER BY 2 desc;

SELECT
    COUNT(*) AS Total_Orders
FROM olist_order_review_dataset AS ord
JOIN olist_order_payment_dataset orderp ON ord.order_id = orderp.order_id
WHERE payment_type = 'credit_card' AND review_score = '5';

-- 3.Average number of days taken for order_delivered_customer_date for pet_shop

SELECT 
round(AVG(DATEDIFF(
        STR_TO_DATE(IFNULL(order_delivered_customer_date, '1970-01-01'), '%Y-%m-%d %H:%i:%s'),
        STR_TO_DATE(IFNULL(order_approved_at, '1970-01-01'), '%Y-%m-%d %H:%i:%s')
    )),2) AS Average_Days
FROM olist_orders_dataset AS orders
JOIN olist_orders_items_dataset AS oid ON orders.order_id = oid.order_id
JOIN olist_products_dataset AS op ON oid.product_id = op.product_id
WHERE op.product_category_name = 'pet_shop';

-- 4.Average price and payment values from customers of sao paulo city

Select count(Distinct(geolocation_city)) from olist_geolocation_dataset;

SELECT 
    round(AVG(oid.price),2) AS average_price,
    round(AVG(op.payment_value),2) AS average_payment_value
FROM olist_orders_items_dataset oid
JOIN olist_orders_dataset o ON oid.order_id = o.order_id
JOIN olist_customer_dataset oc ON o.customer_id = oc.customer_id
JOIN olist_order_payment_dataset op ON op.order_id = o.order_id
WHERE oc.customer_city = 'sao paulo';

-- 5.Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores.

SELECT
ord.review_score as Average_Review_Score,
   round(avg( DATEDIFF(
    STR_TO_DATE(IFNULL(order_delivered_customer_date, '1970-01-01'), '%Y-%m-%d %H:%i:%s'),
    STR_TO_DATE(IFNULL(order_purchase_timestamp, '1970-01-01'), '%Y-%m-%d %H:%i:%s')
  )),2)AS Shipping_Days
FROM olist_orders_dataset AS orders
JOIN olist_order_review_dataset ord on orders.order_id = ord.order_id
GROUP BY Average_Review_Score
ORDER BY Average_Review_Score;

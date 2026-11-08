-- =============================================================
-- theLook Analytics · Fotografia dei dati sorgente
--
-- Perché: il dataset pubblico theLook viene rigenerato. Tra il 7 e
-- l'8 novembre 2026 i ricavi netti di gennaio–settembre 2026 sono
-- passati da $2,20 a $2,22 milioni, e la categoria Suits & Sport
-- Coats da $128K a $140K, con la data di taglio invariata.
-- Senza una copia fissa nessun numero è riproducibile da un giorno
-- all'altro.
--
-- Cosa fa: copia le tabelle pubbliche nel dataset "raw" del tuo
-- progetto. Gli script di staging (01_staging.sql) e il progetto dbt
-- leggono da qui, non più dal dataset pubblico.
-- Per utenti ed eventi copia solo le colonne usate: nomi, email,
-- indirizzi e IP restano fuori dalla copia.
--
-- Come usarlo: incolla tutto in una nuova query e premi Ctrl+Invio.
-- Va eseguito UNA volta. Rieseguirlo cambia la fotografia e quindi
-- tutti i numeri. In sandbox le tabelle scadono dopo 60 giorni.
-- =============================================================

CREATE SCHEMA IF NOT EXISTS raw OPTIONS (
  location = 'US',
  description = 'Fotografia del dataset pubblico thelook_ecommerce'
);


CREATE OR REPLACE TABLE raw.orders AS
SELECT *
FROM `bigquery-public-data.thelook_ecommerce.orders`;


CREATE OR REPLACE TABLE raw.order_items AS
SELECT *
FROM `bigquery-public-data.thelook_ecommerce.order_items`;


CREATE OR REPLACE TABLE raw.products AS
SELECT *
FROM `bigquery-public-data.thelook_ecommerce.products`;


CREATE OR REPLACE TABLE raw.users AS
SELECT
  id,
  age,
  gender,
  country,
  state,
  city,
  traffic_source,
  created_at
FROM `bigquery-public-data.thelook_ecommerce.users`;


CREATE OR REPLACE TABLE raw.events AS
SELECT
  id,
  user_id,
  sequence_number,
  session_id,
  created_at,
  browser,
  traffic_source,
  uri,
  event_type,
  state,
  city
FROM `bigquery-public-data.thelook_ecommerce.events`;


-- Carta d'identità della fotografia: data, righe per tabella e un
-- totale di controllo. Va copiata nel README, così chi rifà la
-- fotografia in futuro può capire se i dati sono cambiati.
SELECT
  CURRENT_DATE('Europe/Rome')                       AS data_fotografia,
  (SELECT COUNT(*) FROM raw.orders)                 AS orders,
  (SELECT COUNT(*) FROM raw.order_items)            AS order_items,
  (SELECT COUNT(*) FROM raw.users)                  AS users,
  (SELECT COUNT(*) FROM raw.products)               AS products,
  (SELECT COUNT(*) FROM raw.events)                 AS events,
  (SELECT ROUND(SUM(oi.sale_price), 2)
     FROM raw.order_items AS oi
     JOIN raw.orders AS o ON oi.order_id = o.order_id
     WHERE LOWER(oi.status) NOT IN ('cancelled', 'returned')
       AND o.created_at >= TIMESTAMP '2026-01-01 00:00:00+00'
       AND o.created_at <  TIMESTAMP '2026-10-01 00:00:00+00')
                                                     AS ricavi_netti_gen_set_2026;

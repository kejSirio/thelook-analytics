-- =============================================================
-- theLook Analytics · 01 · Staging
--
-- Una vista per tabella sorgente: nomi di colonna coerenti, stati
-- in minuscolo, niente dati personali (nomi, email, indirizzi, IP).
--
-- Data di taglio: 30 settembre 2026, ultimo mese completo affidabile.
-- Perché un taglio fisso: il dataset pubblico cresce ogni giorno, e
-- senza taglio i numeri cambiano da un'ora all'altra.
-- Perché settembre e non ottobre: il controllo del 7 novembre ha
-- trovato i dati recenti gonfiati dal generatore. La settimana dal
-- 26 ottobre ha ricavi +29% rispetto alla precedente; la prima di
-- novembre, in 6 giorni, più del doppio di una settimana normale.
-- Per spostare il taglio, cambia la data in tutte le clausole WHERE
-- qui sotto e la fine di dim_date in 02_marts.
--
-- Come usarlo: incolla tutto in una nuova query di BigQuery e premi
-- Ctrl+Invio senza selezionare nulla: parte come script unico.
-- Le viste finiscono nel dataset "staging" del tuo progetto.
-- In sandbox scadono dopo 60 giorni: basta rieseguire lo script.
--
-- La location deve essere US, come il dataset pubblico di origine.
-- =============================================================

CREATE SCHEMA IF NOT EXISTS staging OPTIONS (location = 'US');


-- Raccordo dei canali: iscrizione e sessioni usano etichette diverse.
-- Le ipotesi sono scritte accanto a ogni riga, perché vanno dichiarate
-- nel readout. Con dbt questa tabella diventerà un seed (un CSV).
CREATE OR REPLACE VIEW staging.stg_channel_map AS
SELECT *
FROM UNNEST([
  STRUCT("Search" AS source_label, "Paid Search" AS channel_group,
         "Ipotesi: a pagamento, perché la ricerca organica ha già l'etichetta Organic" AS assumption),
  ("Adwords",  "Paid Search",    "Google Ads"),
  ("Organic",  "Organic Search", "Ipotesi: traffico organico dai motori di ricerca"),
  ("Email",    "Email",          ""),
  ("Facebook", "Social",         "Non si distingue tra organico e a pagamento"),
  ("YouTube",  "Video",          "Non si distingue tra organico e a pagamento"),
  ("Display",  "Display",        "")
]);


CREATE OR REPLACE VIEW staging.stg_orders AS
SELECT
  order_id,
  user_id,
  LOWER(status)  AS status,
  created_at,
  shipped_at,
  delivered_at,
  returned_at,
  num_of_item    AS num_items
FROM `bigquery-public-data.thelook_ecommerce.orders`
WHERE created_at < TIMESTAMP '2026-10-01 00:00:00+00';


CREATE OR REPLACE VIEW staging.stg_order_items AS
SELECT
  id             AS order_item_id,
  order_id,
  user_id,
  product_id,
  LOWER(status)  AS status,
  created_at,
  shipped_at,
  delivered_at,
  returned_at,
  sale_price
FROM `bigquery-public-data.thelook_ecommerce.order_items`
WHERE created_at < TIMESTAMP '2026-10-01 00:00:00+00';


CREATE OR REPLACE VIEW staging.stg_users AS
SELECT
  id             AS user_id,
  age,
  gender,
  country,
  state,
  city,
  traffic_source AS signup_source,
  created_at
FROM `bigquery-public-data.thelook_ecommerce.users`
WHERE created_at < TIMESTAMP '2026-10-01 00:00:00+00';


CREATE OR REPLACE VIEW staging.stg_products AS
SELECT
  id             AS product_id,
  name           AS product_name,
  brand,
  category,
  department,
  cost,
  retail_price,
  distribution_center_id
FROM `bigquery-public-data.thelook_ecommerce.products`;


CREATE OR REPLACE VIEW staging.stg_events AS
SELECT
  id                 AS event_id,
  user_id,
  session_id,
  sequence_number,
  created_at,
  browser,
  traffic_source     AS session_source,
  LOWER(event_type)  AS event_type,
  uri,
  state,
  city
FROM `bigquery-public-data.thelook_ecommerce.events`
WHERE created_at < TIMESTAMP '2026-10-01 00:00:00+00';

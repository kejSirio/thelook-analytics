-- =============================================================
-- theLook Analytics · 02 · Mart a stella
--
-- Dimensioni: dim_date, dim_users, dim_products
-- Fatti:      fct_order_items (riga d'ordine), fct_orders (ordine),
--             fct_sessions (sessione web)
--
-- Definizioni condivise (le stesse andranno in DAX e in MetricFlow):
--   ricavi lordi = vendite esclusi gli articoli cancellati
--   ricavi netti = vendite esclusi articoli cancellati e resi
--   coorte      = mese del primo ordine non cancellato
--
-- Come usarlo: esegui prima 01_staging.sql, poi incolla questo file
-- in una nuova query e premi Ctrl+Invio. Le ultime due query
-- servono a controllare il risultato.
-- =============================================================

CREATE SCHEMA IF NOT EXISTS marts OPTIONS (location = 'US');


-- Calendario dal 2019 alla data di taglio (vedi 01_staging.sql),
-- da segnare come "tabella date" in Power BI
CREATE OR REPLACE VIEW marts.dim_date AS
SELECT
  d                                        AS date,
  EXTRACT(YEAR FROM d)                     AS year,
  EXTRACT(QUARTER FROM d)                  AS quarter,
  EXTRACT(MONTH FROM d)                    AS month,
  DATE_TRUNC(d, MONTH)                     AS month_start,
  FORMAT_DATE('%Y-%m', d)                  AS year_month,
  EXTRACT(ISOWEEK FROM d)                  AS iso_week,
  EXTRACT(DAYOFWEEK FROM d)                AS day_of_week,    -- 1 = domenica
  EXTRACT(DAYOFWEEK FROM d) IN (1, 7)      AS is_weekend,
  d < DATE_TRUNC(CURRENT_DATE(), MONTH)    AS is_complete_month
FROM UNNEST(GENERATE_DATE_ARRAY(DATE '2019-01-01', DATE '2026-09-30')) AS d;


CREATE OR REPLACE VIEW marts.dim_products AS
SELECT *
FROM staging.stg_products;


CREATE OR REPLACE VIEW marts.dim_users AS
WITH first_orders AS (
  SELECT
    user_id,
    MIN(created_at) AS first_order_at,
    COUNT(*)        AS lifetime_orders
  FROM staging.stg_orders
  WHERE status != 'cancelled'
  GROUP BY user_id
)
SELECT
  u.user_id,
  u.age,
  u.gender,
  u.country,
  u.state,
  u.city,
  u.signup_source,
  COALESCE(m.channel_group, 'Altro')          AS signup_channel,
  DATE(u.created_at)                          AS signup_date,
  DATE(f.first_order_at)                      AS first_order_date,
  DATE_TRUNC(DATE(f.first_order_at), MONTH)   AS cohort_month,
  COALESCE(f.lifetime_orders, 0)              AS lifetime_orders
FROM staging.stg_users AS u
LEFT JOIN first_orders AS f
  USING (user_id)
LEFT JOIN staging.stg_channel_map AS m
  ON u.signup_source = m.source_label;


CREATE OR REPLACE VIEW marts.fct_order_items AS
SELECT
  oi.order_item_id,
  oi.order_id,
  oi.user_id,
  oi.product_id,
  DATE(oi.created_at)            AS order_date,
  oi.status,
  oi.sale_price,
  p.cost,
  oi.sale_price - p.cost         AS margin,
  oi.status = 'cancelled'        AS is_cancelled,
  oi.status = 'returned'         AS is_returned
FROM staging.stg_order_items AS oi
LEFT JOIN staging.stg_products AS p
  USING (product_id);


CREATE OR REPLACE VIEW marts.fct_orders AS
WITH items AS (
  SELECT
    order_id,
    COUNT(*)                                                    AS items,
    SUM(IF(status != 'cancelled', sale_price, 0))               AS gross_revenue,
    SUM(IF(status NOT IN ('cancelled', 'returned'), sale_price, 0)) AS net_revenue
  FROM staging.stg_order_items
  GROUP BY order_id
)
SELECT
  o.order_id,
  o.user_id,
  DATE(o.created_at)  AS order_date,
  o.created_at,
  o.status,
  i.items,
  i.gross_revenue,
  i.net_revenue,
  -- Numero progressivo dell'ordine per cliente, contando solo
  -- gli ordini non cancellati (1 = primo acquisto)
  IF(o.status = 'cancelled', NULL,
     ROW_NUMBER() OVER (
       PARTITION BY o.user_id, o.status = 'cancelled'
       ORDER BY o.created_at, o.order_id
     ))               AS user_order_number,
  -- Mesi trascorsi dal mese della coorte (0 = mese del primo acquisto):
  -- è la colonna della matrice di retention in Power BI
  IF(o.status = 'cancelled', NULL,
     DATE_DIFF(DATE_TRUNC(DATE(o.created_at), MONTH), u.cohort_month, MONTH)
  )                   AS months_since_first_order
FROM staging.stg_orders AS o
LEFT JOIN items AS i
  USING (order_id)
LEFT JOIN marts.dim_users AS u
  USING (user_id);


-- Una riga per sessione web. Se la query 7 di esplorazione ha mostrato
-- nomi diversi da 'product', 'cart' e 'purchase', cambiali qui.
CREATE OR REPLACE VIEW marts.fct_sessions AS
WITH sessions AS (
  SELECT
    session_id,
    MAX(user_id)                                    AS user_id,
    MAX(user_id) IS NOT NULL                        AS is_registered,
    MIN(created_at)                                 AS session_start,
    DATE(MIN(created_at))                           AS session_date,
    ARRAY_AGG(session_source IGNORE NULLS ORDER BY sequence_number LIMIT 1)[SAFE_OFFSET(0)] AS session_source,
    ARRAY_AGG(browser IGNORE NULLS ORDER BY sequence_number LIMIT 1)[SAFE_OFFSET(0)]        AS browser,
    COUNT(*)                                        AS events,
    COUNTIF(event_type = 'product')  > 0            AS viewed_product,
    COUNTIF(event_type = 'cart')     > 0            AS added_to_cart,
    COUNTIF(event_type = 'purchase') > 0            AS purchased
  FROM staging.stg_events
  GROUP BY session_id
)
SELECT
  s.*,
  COALESCE(m.channel_group, 'Altro') AS session_channel
FROM sessions AS s
LEFT JOIN staging.stg_channel_map AS m
  ON s.session_source = m.source_label;


-- Controllo 1: quante righe ha ogni mart
SELECT 'dim_date' AS vista, COUNT(*) AS righe FROM marts.dim_date
UNION ALL SELECT 'dim_users',       COUNT(*) FROM marts.dim_users
UNION ALL SELECT 'dim_products',    COUNT(*) FROM marts.dim_products
UNION ALL SELECT 'fct_order_items', COUNT(*) FROM marts.fct_order_items
UNION ALL SELECT 'fct_orders',      COUNT(*) FROM marts.fct_orders
UNION ALL SELECT 'fct_sessions',    COUNT(*) FROM marts.fct_sessions;


-- Controllo 2: i ricavi netti devono coincidere nei due fatti
SELECT
  (SELECT ROUND(SUM(net_revenue), 2) FROM marts.fct_orders) AS netti_da_ordini,
  (SELECT ROUND(SUM(sale_price), 2)
     FROM marts.fct_order_items
     WHERE NOT is_cancelled AND NOT is_returned)            AS netti_da_righe;


-- Controllo 3: il funnel ha variabilità?
-- Se le sessioni degli utenti registrati arrivano quasi tutte
-- all'acquisto e quelle anonime quasi mai, il funnel dipende da come
-- il generatore crea le sessioni, non dal comportamento: va saputo
-- prima di costruirci sopra la pagina di Power BI.
SELECT
  is_registered,
  session_channel,
  COUNT(*)                                            AS sessioni,
  ROUND(100 * COUNTIF(viewed_product) / COUNT(*), 1)  AS pct_prodotto,
  ROUND(100 * COUNTIF(added_to_cart)  / COUNT(*), 1)  AS pct_carrello,
  ROUND(100 * COUNTIF(purchased)      / COUNT(*), 1)  AS pct_acquisto
FROM marts.fct_sessions
GROUP BY is_registered, session_channel
ORDER BY is_registered, sessioni DESC;

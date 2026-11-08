-- =============================================================
-- theLook Analytics · 00 · Esplorazione del dataset
-- Dataset: bigquery-public-data.thelook_ecommerce
--
-- Come usarlo: incolla tutto nell'editor di BigQuery, seleziona
-- UNA query alla volta (dal commento fino al punto e virgola)
-- e premi Ctrl+Invio. Prima di eseguire, in alto a destra
-- BigQuery mostra quanti dati leggerà: qui siamo sempre nell'ordine
-- dei MB, lontanissimi dal limite gratuito di 1 TB al mese.
-- =============================================================


-- 1. Quante righe e quanti MB ha ogni tabella
--    Legge solo i metadati: costa zero.
SELECT
  table_id,
  row_count,
  ROUND(size_bytes / 1e6, 1) AS mb
FROM `bigquery-public-data.thelook_ecommerce.__TABLES__`
ORDER BY row_count DESC;


-- 2. Colonne e tipi di dato di tutte le tabelle
SELECT
  table_name,
  column_name,
  data_type
FROM `bigquery-public-data.thelook_ecommerce.INFORMATION_SCHEMA.COLUMNS`
ORDER BY table_name, ordinal_position;


-- 3. Periodo coperto da ogni tabella
--    Controlla anche se ci sono date nel futuro rispetto a oggi.
SELECT 'orders' AS tabella, MIN(created_at) AS prima_data, MAX(created_at) AS ultima_data, COUNT(*) AS righe
FROM `bigquery-public-data.thelook_ecommerce.orders`
UNION ALL
SELECT 'order_items', MIN(created_at), MAX(created_at), COUNT(*)
FROM `bigquery-public-data.thelook_ecommerce.order_items`
UNION ALL
SELECT 'users', MIN(created_at), MAX(created_at), COUNT(*)
FROM `bigquery-public-data.thelook_ecommerce.users`
UNION ALL
SELECT 'events', MIN(created_at), MAX(created_at), COUNT(*)
FROM `bigquery-public-data.thelook_ecommerce.events`;


-- 4. Ordini e clienti per mese
--    Serve a vedere l'andamento e qual è l'ultimo mese completo.
SELECT
  DATE_TRUNC(DATE(created_at), MONTH) AS mese,
  COUNT(*) AS ordini,
  COUNT(DISTINCT user_id) AS clienti
FROM `bigquery-public-data.thelook_ecommerce.orders`
GROUP BY mese
ORDER BY mese;


-- 5. Ordini per giorno negli ultimi 60 giorni
--    Un'analisi di inizio novembre segnalava un possibile problema
--    a fine ottobre 2026: qui si vede se ci sono buchi o picchi strani.
SELECT
  DATE(created_at) AS giorno,
  COUNT(*) AS ordini
FROM `bigquery-public-data.thelook_ecommerce.orders`
WHERE created_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 60 DAY)
GROUP BY giorno
ORDER BY giorno;


-- 6. Stati degli ordini (completati, spediti, resi, cancellati...)
SELECT
  status,
  COUNT(*) AS ordini,
  ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS percentuale
FROM `bigquery-public-data.thelook_ecommerce.orders`
GROUP BY status
ORDER BY ordini DESC;


-- 7. Tipi di evento web: quali pagine e azioni sono tracciate
SELECT
  event_type,
  COUNT(*) AS eventi,
  COUNT(DISTINCT session_id) AS sessioni
FROM `bigquery-public-data.thelook_ecommerce.events`
GROUP BY event_type
ORDER BY eventi DESC;


-- 8. Sorgenti di traffico delle sessioni
SELECT
  traffic_source,
  COUNT(DISTINCT session_id) AS sessioni,
  ROUND(100 * COUNT(DISTINCT session_id)
        / SUM(COUNT(DISTINCT session_id)) OVER (), 1) AS percentuale
FROM `bigquery-public-data.thelook_ecommerce.events`
GROUP BY traffic_source
ORDER BY sessioni DESC;


-- 9. Quante sessioni sono di utenti registrati e quante anonime
SELECT
  COUNT(DISTINCT session_id) AS sessioni,
  COUNT(DISTINCT IF(user_id IS NULL, session_id, NULL)) AS sessioni_anonime,
  COUNT(DISTINCT user_id) AS utenti_con_sessioni
FROM `bigquery-public-data.thelook_ecommerce.events`;


-- 10. La sorgente della sessione cambia rispetto a quella con cui
--     l'utente si è registrato? Se coincide sempre, l'attribution
--     multi-touch non ha niente da dire: va verificato subito.
SELECT
  u.traffic_source AS sorgente_iscrizione,
  e.traffic_source AS sorgente_sessione,
  COUNT(DISTINCT e.session_id) AS sessioni
FROM `bigquery-public-data.thelook_ecommerce.events` AS e
JOIN `bigquery-public-data.thelook_ecommerce.users` AS u
  ON e.user_id = u.id
GROUP BY sorgente_iscrizione, sorgente_sessione
ORDER BY sessioni DESC;


-- 11. Funnel grezzo: quante sessioni arrivano a prodotto, carrello, acquisto
--     Se la query 7 mostra nomi diversi per i tipi di evento,
--     sostituiscili qui sotto.
SELECT
  COUNT(DISTINCT session_id) AS sessioni,
  COUNT(DISTINCT IF(event_type = 'product',  session_id, NULL)) AS vista_prodotto,
  COUNT(DISTINCT IF(event_type = 'cart',     session_id, NULL)) AS carrello,
  COUNT(DISTINCT IF(event_type = 'purchase', session_id, NULL)) AS acquisto
FROM `bigquery-public-data.thelook_ecommerce.events`;


-- 12. Valori dei canali nelle due tabelle
--     Iscrizione e sessione usano etichette diverse (es. "Search"
--     contro "Adwords"): serve una tabella di raccordo dei canali.
SELECT 'iscrizione' AS dove, traffic_source, COUNT(*) AS righe
FROM `bigquery-public-data.thelook_ecommerce.users`
GROUP BY traffic_source
UNION ALL
SELECT 'sessione', traffic_source, COUNT(DISTINCT session_id)
FROM `bigquery-public-data.thelook_ecommerce.events`
GROUP BY traffic_source
ORDER BY dove, righe DESC;


-- 13. Per ogni canale di iscrizione, come si dividono le sessioni successive
--     Leggi la colonna pct_nella_riga: se le percentuali sono quasi
--     uguali per tutti i canali di iscrizione, il generatore assegna
--     il canale di sessione a caso. In quel caso l'attribution
--     mostrerà canali molto simili tra loro, e va detto nel readout.
SELECT
  u.traffic_source AS sorgente_iscrizione,
  e.traffic_source AS sorgente_sessione,
  COUNT(DISTINCT e.session_id) AS sessioni,
  ROUND(100 * COUNT(DISTINCT e.session_id)
        / SUM(COUNT(DISTINCT e.session_id)) OVER (PARTITION BY u.traffic_source), 1) AS pct_nella_riga
FROM `bigquery-public-data.thelook_ecommerce.events` AS e
JOIN `bigquery-public-data.thelook_ecommerce.users` AS u
  ON e.user_id = u.id
GROUP BY sorgente_iscrizione, sorgente_sessione
ORDER BY sorgente_iscrizione, pct_nella_riga DESC;

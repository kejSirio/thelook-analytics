# Guida al modello

Per chi entra nel progetto: come sono organizzati i dati, come si ricostruisce tutto e quali errori evitare. Si legge in dieci minuti.

## 1. Il percorso dei dati

```
bigquery-public-data.thelook_ecommerce     dati pubblici, sintetici, rigenerati nel tempo
        │
        ▼  sql/00_fotografia_dati.sql (una volta sola)
raw.*                                       copia fissa: i numeri restano riproducibili
        │
        ▼  sql/01_staging.sql  oppure  dbt (cartella dbt/)
staging.stg_*                               pulizia, nomi coerenti, data di taglio
        │
        ▼  sql/02_marts.sql
marts.dim_* e marts.fct_*                   schema a stella, definizioni condivise
        │
        ├──▶ Power BI (powerbi/)            report Vendite e Clienti
        └──▶ notebook (notebooks/)          test statistici
```

Ogni livello legge solo da quello precedente. Power BI e i notebook leggono solo da `marts`, mai da `staging` o dai dati grezzi.

## 2. Ricostruire tutto da zero

1. In un progetto Google Cloud con BigQuery attivo (basta la sandbox gratuita), esegui una volta `sql/00_fotografia_dati.sql`, poi `sql/01_staging.sql` e `sql/02_marts.sql`. Ogni file va eseguito intero, con Ctrl+Invio. In alternativa agli ultimi due, esegui il progetto dbt con `notebooks/02_dbt_metricflow.ipynb`, che scrive in `dbt_staging` e `dbt_marts`.
2. Controlla i risultati in fondo a `02_marts.sql`: le righe per tabella e i ricavi netti, che devono coincidere calcolati in due modi.
3. Apri `powerbi/analisi.pbix` e aggiorna i dati. Se colleghi un modello nuovo, segui `powerbi/modello_e_misure.md`.
4. Esegui i notebook in Google Colab con lo stesso account Google.

In sandbox tabelle e viste scadono dopo 60 giorni. Le viste si ricreano rieseguendo gli script; la fotografia invece, se rifatta, contiene dati diversi, perché il dataset pubblico nel frattempo è stato rigenerato. Confronta la sua "carta d'identità" (righe e totale di controllo in fondo allo script) con quella riportata nel README.

## 3. Le tabelle

| Tabella | Una riga è | Chiave | Serve per |
| --- | --- | --- | --- |
| `dim_date` | un giorno, dal 2019 alla data di taglio | `date` | filtri e confronti nel tempo |
| `dim_users` | un cliente | `user_id` | canale di iscrizione, coorte, numero di ordini |
| `dim_products` | un prodotto | `product_id` | categoria, marca, costo |
| `fct_order_items` | una riga d'ordine | `order_item_id` | ricavi, margine, resi per prodotto |
| `fct_orders` | un ordine | `order_id` | ordini, valore medio, nuovi clienti e clienti di ritorno, coorti |
| `fct_sessions` | una sessione web | `session_id` | canali di sessione; il funnel non è affidabile (sezione 7) |

Prima di scrivere una misura chiediti a quale livello vive il numero: i ricavi per categoria stanno sulle righe d'ordine, il valore medio dell'ordine sugli ordini. Prendere la tabella sbagliata è l'errore più comune.

## 4. Le definizioni

Sono nella tabella "Definizioni condivise" del README. Ogni metrica ha **una sola** definizione, scritta uguale in tre posti:

- nel commento in testa a `sql/02_marts.sql`;
- nella misura DAX (`powerbi/misure_tutte.dax`);
- nella tabella del README.

## 5. Aggiungere una metrica

1. Scrivi la definizione in una frase, prima del codice. Esempio: "clienti di ritorno = clienti con almeno un ordine non cancellato che non è il loro primo".
2. Se servono colonne nuove, aggiungile nel mart in `02_marts.sql`, non in Power BI.
3. Crea la misura DAX nella tabella `_Misure`, con un nome in italiano e il formato giusto (valuta, percentuale, intero).
4. Aggiungi la riga nella tabella delle definizioni del README.
5. Verifica il numero in due modi: in BigQuery con una query e in Power BI con una scheda, senza filtri.

## 6. Spostare la data di taglio

La data compare in due punti:

- nelle quattro clausole `WHERE created_at < TIMESTAMP '…'` di `01_staging.sql`;
- nella fine di `GENERATE_DATE_ARRAY` in `02_marts.sql`, che è il giorno precedente.

Cambiale insieme, riesegui i due script e aggiorna Power BI. Prima di spostarla in avanti, ripeti il controllo dei ricavi settimanali descritto nel README: il generatore gonfia i giorni più recenti.

## 7. Trappole note

- **I dati sono sintetici.** Il canale delle sessioni è indipendente da quello di iscrizione. Il funnel segue regole fisse: le sessioni anonime non comprano mai, quelle registrate quasi sempre. C'è una sessione d'acquisto per ogni riga d'ordine. Non trarre conclusioni di business da funnel e canali di sessione.
- **Percentuali in Power BI.** Sono numeri decimali: il 7% si scrive 0,07 nelle soglie e nelle scale di colore.
- **Coorti.** Le misure della matrice ignorano apposta i filtri sulle date (`REMOVEFILTERS ( dim_date )`), perché seguono ogni coorte per tutta la sua storia. Non aggiungere filtri di data sulla matrice aspettandoti che funzionino.
- **Date automatiche.** In Power BI l'opzione "Data/ora automatica" deve restare spenta: il calendario è `dim_date`.
- **Separatori DAX.** Se una formula dà errore sulla virgola, controlla in Opzioni → Impostazioni internazionali che i separatori DAX siano quelli standard.

## 8. Convenzioni

- **Tabelle:** `stg_` per lo staging, `dim_` per le dimensioni, `fct_` per i fatti.
- **Colonne:** in inglese, minuscolo, con il trattino basso. Le misure DAX invece sono in italiano, perché le legge il cliente.
- **Report:** un solo colore d'accento, usato per il dato che il titolo commenta; tutto il resto in grigio.
- **Titoli dei grafici:** dicono cosa si vede ("Giacche e jeans valgono quasi un quarto dei ricavi"), non il nome della misura. Il sottotitolo dice cosa c'è nel grafico e su quale periodo.

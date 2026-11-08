# theLook Analytics

Progetto portfolio impostato come un ingaggio di consulenza: dai dati grezzi di un e-commerce a un modello a stella, metriche condivise, report Power BI, analisi statistiche e raccomandazioni per il management.

## Il brief

Il cliente è theLook, un negozio online di abbigliamento. Il management chiede risposta a cinque domande:

1. Quali canali portano clienti che tornano a comprare, e quanto vale ciascuno oltre il last click? *(attribution)*
2. Dove si perde il funnel prodotto → carrello → acquisto, e cambia per canale o browser? *(funnel)*
3. I clienti acquisiti nel 2025 tornano a comprare più o meno di quelli del 2024? *(cohort)*
4. Quali categorie aprono il primo acquisto, e quali hanno più resi? *(analisi descrittiva)*
5. Quale variante di un esperimento migliora la conversione, e per chi? *(A/B test)*

## Dati

- **Fonte principale**: `bigquery-public-data.thelook_ecommerce`, dataset pubblico di Google su BigQuery: utenti, ordini, righe d'ordine, prodotti, magazzino ed eventi web, da febbraio 2019 a oggi.
- **A/B test**: [E-Commerce Clickstream Simulation Dataset](https://www.kaggle.com/datasets/amith1707/e-commerce-clickstream-simulation-dataset) su Kaggle, licenza CC0.
- **Limiti**: entrambi i dataset sono sintetici. I risultati mostrano il metodo, non il comportamento di un'azienda reale.
- **Data di taglio: 30 settembre 2026.** Il controllo settimanale dei ricavi ha trovato dati recenti gonfiati dal generatore: la settimana dal 26 ottobre +29% rispetto alla precedente, la prima di novembre più del doppio di una settimana normale in soli 6 giorni. Ottobre quindi non è un mese affidabile.

## Stato

- [ ] Esplorazione dei dati (`sql/00_esplorazione.sql`)
- [ ] Modello a stella: staging e mart
- [ ] Report Power BI con misure DAX
- [ ] Retention per coorte
- [ ] Modelli dbt con test e semantic layer (MetricFlow)
- [ ] Funnel, attribution e A/B test
- [ ] Dashboard Tableau Public e readout per il management

## Struttura

```
sql/          esplorazione, staging e mart come script BigQuery
models/       gli stessi staging e mart come modelli dbt, con test
notebooks/    analisi in Python
powerbi/      report Power BI e screenshot
docs/         readout, memo e guida per chi entra nel progetto
```

## Autore

Stefano Manco · [stefanomanco.it](https://stefanomanco.it)

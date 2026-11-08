# theLook Analytics

Progetto portfolio impostato come un ingaggio di consulenza: dai dati grezzi di un e-commerce a un modello a stella, metriche condivise, report Power BI, analisi statistiche e raccomandazioni per il management.

**Stack:** BigQuery (SQL) · modello a stella · Power BI e DAX · Python · dbt e MetricFlow (in corso)

## Il brief

Il cliente è theLook, un negozio online di abbigliamento. Il management chiede risposta a cinque domande:

1. Quali canali portano clienti che tornano a comprare, e quanto vale ciascuno oltre il last click? *(attribution)*
2. Dove si perde il funnel prodotto → carrello → acquisto, e cambia per canale o browser? *(funnel)*
3. I clienti acquisiti nel 2026 tornano a comprare più o meno di quelli del 2025? *(cohort)*
4. Quali categorie aprono il primo acquisto, e quali hanno più resi? *(analisi descrittiva)*
5. Quale variante di un esperimento migliora la conversione, e per chi? *(A/B test)*

## Primi risultati (gennaio–settembre 2026)

- **Ricavi:** $2,20 milioni netti, +74,9% sullo stesso periodo del 2025. A settembre i ricavi mensili sono il doppio di settembre 2025.
- **Categorie:** giacche e jeans valgono quasi un quarto dei ricavi ($524K su $2,20 milioni).
- **Resi:** 11,7% degli articoli venduti, con poche differenze tra le categorie (dal 10,5% al 13,1%).
- **Clienti:** 24.000 clienti acquirenti, il 41,8% dei quali già cliente in precedenza. I clienti di ritorno passano da 1.000 a gennaio a 1.800 a settembre.
- **Coorti:** entro 90 giorni dal primo acquisto ricompra il 12,5% dei clienti del 2026 contro il 7,6% di quelli del 2025: +4,9 punti percentuali, con intervallo di confidenza al 95% da 4,2 a 5,7. Non è un salto ma una crescita continua, di circa mezzo punto per ogni mese di coorte (R² 0,83).
- **Canali:** 7 clienti su 10 si sono iscritti da Paid Search. Il canale da cui arrivano le sessioni successive è indipendente da quello di iscrizione (chi-quadro p = 0,13; V di Cramér 0,006): un modello di attribution non avrebbe segnale su cui lavorare.

La sintesi per il management, con tre raccomandazioni, è in [`docs/memo.md`](docs/memo.md).

### Vendite

![Pagina Vendite del report Power BI](powerbi/vendite.png)

### Clienti

![Pagina Clienti del report Power BI](powerbi/clienti.png)

## Dati e loro limiti

- **Fonte principale:** `bigquery-public-data.thelook_ecommerce`, dataset pubblico di Google su BigQuery: utenti, ordini, righe d'ordine, prodotti, magazzino ed eventi web, da febbraio 2019.
- **A/B test:** [E-Commerce Clickstream Simulation Dataset](https://www.kaggle.com/datasets/amith1707/e-commerce-clickstream-simulation-dataset) su Kaggle, licenza CC0.
- **Dati sintetici:** i risultati mostrano il metodo, non il comportamento di un'azienda reale.
- **Fotografia dei dati.** Il dataset pubblico viene rigenerato: tra il 7 e l'8 novembre 2026 i ricavi netti di gennaio–settembre 2026 sono passati da $2,20 a $2,22 milioni, con la data di taglio invariata. La differenza è emersa confrontando Power BI e MetricFlow. Per questo il progetto lavora su una copia fissa (`sql/00_fotografia_dati.sql`, dataset `raw`), e i numeri di questo README si riferiscono a quella copia.
- **Data di taglio: 30 settembre 2026.** Il controllo settimanale dei ricavi ha trovato dati recenti gonfiati dal generatore: la settimana dal 26 ottobre +29% rispetto alla precedente, la prima di novembre più del doppio di una settimana normale in soli 6 giorni. Ottobre quindi non è un mese affidabile.
- **Cosa il generatore decide da solo**, verificato in fase di esplorazione:
  - il canale di ogni sessione è indipendente da quello di iscrizione;
  - il funnel segue regole fisse: le sessioni anonime non comprano mai, quelle registrate quasi sempre;
  - viene creata una sessione d'acquisto per ogni riga d'ordine.

  Per questo funnel e attribution non si fanno su theLook. Anche la crescita dei ricavi e il miglioramento delle coorti recenti potrebbero dipendere dal generatore più che dal comportamento dei clienti.

## Definizioni condivise

| Metrica | Definizione |
| --- | --- |
| Ricavi lordi | Vendite esclusi gli articoli cancellati |
| Ricavi netti | Vendite esclusi gli articoli cancellati e resi |
| Ordini | Ordini non cancellati |
| Coorte | Mese del primo ordine non cancellato |
| Retention % | Clienti della coorte che comprano in un dato mese, sul totale della coorte |

Le stesse definizioni sono in `sql/02_marts.sql` e nelle misure DAX (`powerbi/misure_tutte.dax`).

## Stato

- [x] Esplorazione dei dati (`sql/00_esplorazione.sql`)
- [x] Modello a stella: staging e mart (`sql/01_staging.sql`, `sql/02_marts.sql`)
- [x] Report Power BI con 17 misure DAX e matrice delle coorti
- [x] Test statistici su coorti e canali (`notebooks/01_coorti_e_canali.ipynb`)
- [x] Memo per il management e guida al modello (`docs/`)
- [ ] Modelli dbt con test e semantic layer (MetricFlow)
- [ ] Funnel, attribution e A/B test
- [ ] Dashboard Tableau Public e readout per il management

## Struttura

```
sql/          esplorazione, fotografia dei dati, staging e mart come script BigQuery
dbt/          gli stessi staging e mart come progetto dbt: test, controllo anomalie, semantic layer MetricFlow
powerbi/      report Power BI, misure DAX, guida al modello, screenshot
notebooks/    01 test statistici su coorti e canali, 02 build dbt e metriche MetricFlow (Google Colab)
docs/         memo per il management, guida al modello per chi entra nel progetto
```

## Autore

Stefano Manco · [stefanomanco.it](https://stefanomanco.it)

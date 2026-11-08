# Power BI · modello e misure DAX

## 1. Relazioni

Vista Modello (terza icona a sinistra). Power BI prova a indovinare alcune relazioni dai nomi delle colonne: **elimina qualsiasi relazione tra due tabelle `fct_`**, perché i fatti si collegano solo attraverso le dimensioni.

Poi crea queste sette relazioni trascinando la colonna della dimensione sulla colonna del fatto. Tutte uno-a-molti, filtro a direzione singola (dalla dimensione al fatto).

| Dimensione (lato 1) | Fatto (lato molti) |
| --- | --- |
| `dim_date[date]` | `fct_orders[order_date]` |
| `dim_date[date]` | `fct_order_items[order_date]` |
| `dim_date[date]` | `fct_sessions[session_date]` |
| `dim_users[user_id]` | `fct_orders[user_id]` |
| `dim_users[user_id]` | `fct_order_items[user_id]` |
| `dim_users[user_id]` | `fct_sessions[user_id]` |
| `dim_products[product_id]` | `fct_order_items[product_id]` |

Infine seleziona `dim_date` e scegli **Strumenti tabella → Segna come tabella date**, colonna `date`. Senza questo passaggio le funzioni di time intelligence non funzionano.

## 2. Tabella delle misure

Per tenere ordinate le misure: **Home → Immetti dati**, nome tabella `_Misure`, conferma con la tabella vuota. Ogni misura qui sotto si crea con la tabella `_Misure` selezionata e **Nuova misura**, incollando una misura alla volta.

## 3. Misure

Le definizioni sono le stesse scritte in testa a `sql/02_marts.sql`.

### Vendite

```dax
Ricavi lordi =
CALCULATE (
    SUM ( fct_order_items[sale_price] ),
    fct_order_items[is_cancelled] = FALSE ()
)
```

```dax
Ricavi netti =
CALCULATE (
    SUM ( fct_order_items[sale_price] ),
    fct_order_items[is_cancelled] = FALSE (),
    fct_order_items[is_returned] = FALSE ()
)
```

```dax
Margine =
CALCULATE (
    SUM ( fct_order_items[margin] ),
    fct_order_items[is_cancelled] = FALSE (),
    fct_order_items[is_returned] = FALSE ()
)
```

```dax
Margine % = DIVIDE ( [Margine], [Ricavi netti] )
```

```dax
Ordini =
CALCULATE (
    COUNTROWS ( fct_orders ),
    fct_orders[status] <> "cancelled"
)
```

```dax
Valore medio ordine =
DIVIDE (
    CALCULATE ( SUM ( fct_orders[gross_revenue] ), fct_orders[status] <> "cancelled" ),
    [Ordini]
)
```

```dax
Tasso di reso =
DIVIDE (
    CALCULATE ( COUNTROWS ( fct_order_items ), fct_order_items[is_returned] = TRUE () ),
    CALCULATE ( COUNTROWS ( fct_order_items ), fct_order_items[is_cancelled] = FALSE () )
)
```

### Confronti nel tempo

```dax
Ricavi netti anno prec. =
CALCULATE ( [Ricavi netti], SAMEPERIODLASTYEAR ( dim_date[date] ) )
```

```dax
Var % anno su anno =
DIVIDE ( [Ricavi netti] - [Ricavi netti anno prec.], [Ricavi netti anno prec.] )
```

```dax
Ricavi netti da inizio anno = TOTALYTD ( [Ricavi netti], dim_date[date] )
```

### Clienti

```dax
Clienti acquirenti =
CALCULATE (
    DISTINCTCOUNT ( fct_orders[user_id] ),
    fct_orders[status] <> "cancelled"
)
```

```dax
Nuovi clienti =
CALCULATE ( DISTINCTCOUNT ( fct_orders[user_id] ), fct_orders[user_order_number] = 1 )
```

```dax
Clienti di ritorno =
CALCULATE ( DISTINCTCOUNT ( fct_orders[user_id] ), fct_orders[user_order_number] > 1 )
```

Nota: un cliente che nello stesso periodo fa il primo ordine e un secondo ordine conta sia tra i nuovi sia tra quelli di ritorno, quindi le due misure possono sommare più dei clienti acquirenti.

### Coorti

Matrice con righe `dim_users[cohort_month]`, colonne `fct_orders[months_since_first_order]`, valori `Retention %`. Le coorti ignorano il filtro sulle date, perché seguono ogni gruppo di clienti per tutta la sua storia.

```dax
Clienti nella coorte =
CALCULATE (
    DISTINCTCOUNT ( fct_orders[user_id] ),
    fct_orders[months_since_first_order] = 0,
    REMOVEFILTERS ( dim_date )
)
```

```dax
Clienti attivi =
CALCULATE (
    DISTINCTCOUNT ( fct_orders[user_id] ),
    fct_orders[status] <> "cancelled",
    REMOVEFILTERS ( dim_date )
)
```

```dax
Retention % = DIVIDE ( [Clienti attivi], [Clienti nella coorte] )
```

## 4. Formati

- Ricavi e margine: valuta, due decimali. Il dataset non dichiara la valuta: usa il dollaro e scrivilo in una nota del report.
- Margine %, Tasso di reso, Var %, Retention %: percentuale, un decimale.

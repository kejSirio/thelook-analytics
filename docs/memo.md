# Memo · Vendite e clienti di theLook, gennaio–settembre 2026

**Per:** direzione di theLook  
**Da:** Stefano Manco  
**Data:** novembre 2026

## In sintesi

L'azienda cresce: i ricavi sono aumentati del 75% rispetto al 2025 e i nuovi clienti tornano a comprare più spesso di quelli dell'anno scorso. I dati però non permettono di dire quali canali generano questa crescita. Prima di investire in un modello di attribution bisogna rendere i dati capaci di rispondere.

## Cosa abbiamo trovato

- **Ricavi:** $2,20 milioni netti da gennaio a settembre, +74,9% sullo stesso periodo del 2025. A settembre i ricavi mensili sono il doppio di un anno prima.
- **Categorie:** giacche e jeans valgono quasi un quarto dei ricavi. I resi sono all'11,7% e cambiano poco da una categoria all'altra, dal 10,5% al 13,1%.
- **Riacquisto:** entro 90 giorni ricompra il 12,5% dei clienti acquisiti nel 2026, contro il 7,6% del 2025. La differenza è statisticamente solida (+4,9 punti, intervallo di confidenza da 4,2 a 5,7) e cresce in modo regolare, di circa mezzo punto per ogni mese di coorte.
- **Canali:** 7 clienti su 10 si iscrivono da Paid Search. Il canale da cui tornano in seguito non dipende da quello di iscrizione: la distribuzione è la stessa per tutti.
- **Qualità dei dati:** da fine ottobre i dati più recenti risultano gonfiati (+29% in una settimana, poi più del doppio). L'analisi si ferma al 30 settembre.

## Tre raccomandazioni

**1. Prima i dati, poi il modello di attribution.**
Oggi il percorso dei clienti tra i canali non ha struttura, quindi un modello multi-touch distribuirebbe il merito in proporzione al traffico, senza informazioni nuove.
*Primo passo:* uniformare le etichette dei canali tra iscrizione e sessioni (oggi "Search" e "Adwords" indicano probabilmente la stessa cosa) e misurare il contributo reale di Paid Search con un test a gruppo di controllo, sospendendo le campagne in alcune aree per qualche settimana.

**2. Capire cosa spinge il riacquisto, prima di attribuirlo a un'iniziativa.**
Una crescita così regolare, mese dopo mese, è un buon segnale ma va spiegata: potrebbe dipendere dall'assortimento, dai prezzi o dalle email ai clienti.
*Primo passo:* fare del riacquisto entro 90 giorni un indicatore ufficiale, con una definizione unica in tutti i report, e scomporlo per canale e categoria del primo acquisto.

**3. Un controllo automatico della qualità prima di ogni report.**
Senza il controllo, i report avrebbero mostrato per ottobre una crescita del 30% sul mese precedente, in buona parte dovuta ai dati gonfiati.
*Primo passo:* un controllo settimanale che confronti ordini e ricavi con le settimane precedenti e blocchi l'aggiornamento dei report quando lo scarto supera una soglia concordata.

## Limiti

I dati sono sintetici, generati da Google per scopi dimostrativi. Alcuni risultati, come la crescita regolare del riacquisto e l'indipendenza tra canali, possono dipendere dalle regole del generatore più che dal comportamento dei clienti. Il metodo resta valido; i numeri vanno letti come un esempio.

Dettagli: report Power BI (`powerbi/`), test statistici (`notebooks/01_coorti_e_canali.ipynb`), definizioni delle metriche (`README.md`).

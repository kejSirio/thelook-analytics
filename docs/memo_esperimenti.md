# Memo · Funnel, canali ed esperimenti sui marketplace, 2023–2024

**Per:** direzione e-commerce  
**Da:** Stefano Manco  
**Data:** novembre 2026

## In sintesi

Il funnel perde quasi tutto al primo passaggio, ma in modo uguale ovunque. L'unico problema localizzato è il checkout di Flipkart, che vale circa $425.000 l'anno. Gli esperimenti degli ultimi due anni non hanno prodotto decisioni perché erano troppo piccoli per vedere effetti realistici. I dati sui canali non permettono di dire quale canale valga di più.

## Cosa abbiamo trovato

- **Funnel:** su 100 visite, 3,2 aggiungono un prodotto al carrello, 1,1 avviano il checkout e 0,8 comprano. Canale, browser e dispositivo non fanno differenza.
- **Flipkart:** arriva al checkout il 15,9% dei carrelli, contro il 37,9% delle altre piattaforme. Il calo è identico su ogni dispositivo, canale, paese e trimestre dal 2023. Con il tasso delle altre piattaforme, Flipkart avrebbe fatto 4.634 acquisti e $849.618 di ricavi in più in due anni.
- **Canali:** ogni cliente arriva sempre dallo stesso canale, e tutti i canali convertono allo stesso modo (tra 0,78% e 0,84%). Cinque modelli di attribution, dal last click alle catene di Markov, danno lo stesso risultato della quota di traffico.
- **Esperimenti:** nessuno dei 6 test ha un effetto certo. Con circa 50.000 utenti per gruppo potevano vedere solo miglioramenti dal 6% in su; per un +5% ne servivano 70.000. Il risultato più promettente è il confronto dei prezzi tra piattaforme nella versione completa: +9,2% di conversione, con il 97% di probabilità di essere un miglioramento reale, ma testato su soli 5.330 utenti.

## Quattro raccomandazioni

**1. Correggere il checkout di Flipkart.**
È il problema più grande e il più circoscritto: riguarda una sola piattaforma, in un solo passaggio, sempre allo stesso modo.
*Primo passo:* ricostruire il passaggio dal carrello al checkout su Flipkart (pagine, dati richiesti, metodi di pagamento) e testare una correzione.

**2. Dimensionare gli esperimenti prima di avviarli.**
Un test troppo piccolo costa come uno giusto ma non porta a una decisione.
*Primo passo:* per ogni nuovo esperimento fissare prima l'effetto minimo che interessa e il numero di utenti necessario; fare meno esperimenti in parallelo, ciascuno abbastanza grande da vedere effetti del 3–5%.

**3. Confermare il confronto prezzi prima di adottarlo.**
Su dodici varianti confrontate, un risultato così può uscire anche per caso.
*Primo passo:* un test dedicato, solo controllo contro versione completa, con circa 21.600 utenti per gruppo.

**4. Misurare i canali con test di incrementalità, non con un modello.**
Se i dati non contengono percorsi tra canali, nessun modello di attribution può ricostruirli.
*Primo passo:* sospendere un canale in alcune aree per qualche settimana e confrontare le vendite con le aree in cui resta attivo.

## Limiti

I dati sono simulati: il metodo resta valido, i numeri vanno letti come un esempio. Alcuni effetti, come il calo di Flipkart, possono essere stati scritti nel generatore. La documentazione del dataset non coincide del tutto con i dati; l'analisi usa i dati ed esclude le sessioni dei bot.

Dettagli: `notebooks/03_ab_test_e_funnel.ipynb`, sezione 6.

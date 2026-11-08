# Memo · Funnel ed esperimenti sui marketplace, 2023–2024

**Per:** direzione e-commerce (scenario di studio)  
**Da:** Stefano Manco  
**Data:** novembre 2026

## In sintesi

Il funnel perde quasi tutto al primo passaggio, ma in modo uguale ovunque. L'unico problema localizzato è il checkout di Flipkart, che vale circa $425.000 l'anno. Gli esperimenti non hanno dato risultati certi perché erano troppo piccoli, ma permettono comunque tre decisioni: lanciare in modo graduale il confronto prezzi completo, abbandonare le versioni leggere e provare in futuro solo idee capaci di spostare la conversione di almeno il 5%.

## Cosa abbiamo trovato

- **Funnel:** su 100 visite, 3,2 aggiungono un prodotto al carrello, 1,1 avviano il checkout e 0,8 comprano. Canale, browser e dispositivo non fanno differenza.
- **Flipkart:** arriva al checkout il 15,9% dei carrelli, contro il 37,9% delle altre piattaforme. Il calo è identico su ogni dispositivo, canale, paese e trimestre dal 2023. Con il tasso delle altre piattaforme, Flipkart avrebbe fatto 4.634 acquisti e $849.618 di ricavi in più in due anni.
- **Esperimenti:** nessuno dei 6 test ha un effetto certo. Con circa 50.000 utenti per gruppo potevano vedere solo miglioramenti dal 6% in su.
- **Il confronto prezzi completo** ha il 97% di probabilità di migliorare la conversione, e se si sbaglia la perdita attesa è dello 0,05%. Il guadagno da aspettarsi però è piccolo: letto insieme agli altri esperimenti, il +9,2% osservato si ridimensiona a circa +0,4%.
- **Versioni complete e leggere:** in tutti e tre gli esperimenti che le confrontano, la versione completa converte più della leggera (+0,4 punti insieme).
- **Canali:** ogni cliente arriva sempre dallo stesso canale e tutti i canali convertono allo stesso modo. Cinque modelli di attribution, Markov compreso, danno lo stesso risultato della quota di traffico.

## Quattro raccomandazioni

**1. Correggere il checkout di Flipkart.**
È il problema più grande e il più circoscritto: una sola piattaforma, un solo passaggio, sempre allo stesso modo.
*Primo passo:* ricostruire il passaggio dal carrello al checkout su Flipkart (pagine, dati richiesti, metodi di pagamento) e testare una correzione.

**2. Lanciare il confronto prezzi completo in modo graduale.**
Il rischio è minimo e aspettare un risultato certo richiederebbe più utenti di quanti ne esistano.
*Primo passo:* attivarlo per una parte degli utenti, con una soglia per tornare indietro fissata prima, e aspettarsi un guadagno piccolo.

**3. Provare solo idee grandi, nella versione completa.**
Con questa base utenti un test vede solo effetti dal 5% in su, e occupa il 28% degli utenti. Le modifiche provate finora valgono in media quasi zero, e le versioni leggere rendono meno di quelle complete.
*Primo passo:* per ogni nuovo esperimento fissare prima l'effetto minimo e il numero di utenti, e fare un esperimento alla volta sulla stessa pagina.

**4. Misurare i canali con un test, non con un modello.**
Se i dati non contengono percorsi tra canali, nessun modello di attribution può ricostruirli.
*Primo passo:* un test geografico: sospendere un canale in alcune aree per qualche settimana e confrontare le vendite con le aree in cui resta attivo. Il notebook 04 lo dimensiona per Paid Search su theLook.

## Limiti

È un progetto di studio su dati simulati: il metodo resta valido, i numeri vanno letti come un esempio. Alcuni effetti, come il calo di Flipkart, possono essere stati scritti nel generatore. La documentazione del dataset non coincide del tutto con i dati; l'analisi usa i dati ed esclude le sessioni dei bot.

Dettagli: `notebooks/03_ab_test_e_funnel.ipynb`, sezioni 6 e 7.

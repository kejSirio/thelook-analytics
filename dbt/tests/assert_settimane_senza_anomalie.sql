-- Controllo qualità: segnala le settimane i cui ricavi netti superano la
-- media delle quattro settimane precedenti di oltre la soglia concordata.
-- Esempio: con una data di taglio a novembre 2026 il test segnala la prima
-- settimana di novembre, con ricavi più che doppi rispetto alla media delle
-- quattro precedenti. È il problema trovato a mano durante l'esplorazione.
{{ config(severity='warn') }}

with settimane as (
  select
    date_trunc(order_date, week(monday)) as settimana,
    sum(net_revenue) as ricavi_netti
  from {{ ref('fct_orders') }}
  where status != 'cancelled'
    and order_date >= date('{{ var("anomaly_start_date") }}')
  group by settimana
),

confronto as (
  select
    settimana,
    ricavi_netti,
    avg(ricavi_netti) over (
      order by settimana
      rows between 4 preceding and 1 preceding
    ) as media_4_settimane
  from settimane
)

select
  settimana,
  ricavi_netti,
  round(media_4_settimane, 0) as media_4_settimane,
  round(ricavi_netti / media_4_settimane - 1, 3) as scarto
from confronto
where media_4_settimane is not null
  and ricavi_netti > media_4_settimane * (1 + {{ var('anomaly_threshold') }})

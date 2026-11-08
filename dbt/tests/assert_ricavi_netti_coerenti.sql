-- I ricavi netti devono coincidere calcolati per ordine e per riga d'ordine.
with per_ordine as (
  select round(sum(net_revenue), 2) as valore from {{ ref('fct_orders') }}
),
per_riga as (
  select round(sum(sale_price), 2) as valore
  from {{ ref('fct_order_items') }}
  where not is_cancelled and not is_returned
)

select per_ordine.valore as da_ordini, per_riga.valore as da_righe
from per_ordine
cross join per_riga
where abs(per_ordine.valore - per_riga.valore) > 0.01

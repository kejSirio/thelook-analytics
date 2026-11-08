-- La data di riferimento è quella dell'ordine, non della singola riga:
-- così ricavi e ordini cadono sempre nello stesso giorno.
select
  oi.order_item_id,
  oi.order_id,
  oi.user_id,
  oi.product_id,
  date(o.created_at) as order_date,
  oi.status,
  oi.sale_price,
  p.cost,
  oi.sale_price - p.cost as margin,
  oi.status = 'cancelled' as is_cancelled,
  oi.status = 'returned' as is_returned
from {{ ref('stg_order_items') }} as oi
inner join {{ ref('stg_orders') }} as o
  on oi.order_id = o.order_id
left join {{ ref('stg_products') }} as p
  on oi.product_id = p.product_id

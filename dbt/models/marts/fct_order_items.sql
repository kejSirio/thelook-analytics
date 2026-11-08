select
  oi.order_item_id,
  oi.order_id,
  oi.user_id,
  oi.product_id,
  date(oi.created_at) as order_date,
  oi.status,
  oi.sale_price,
  p.cost,
  oi.sale_price - p.cost as margin,
  oi.status = 'cancelled' as is_cancelled,
  oi.status = 'returned' as is_returned
from {{ ref('stg_order_items') }} as oi
left join {{ ref('stg_products') }} as p
  using (product_id)

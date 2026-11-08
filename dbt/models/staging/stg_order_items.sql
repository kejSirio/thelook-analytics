select
  id as order_item_id,
  order_id,
  user_id,
  product_id,
  lower(status) as status,
  created_at,
  shipped_at,
  delivered_at,
  returned_at,
  sale_price
from {{ source('thelook', 'order_items') }}
where created_at < timestamp('{{ var("cutoff_date") }}')

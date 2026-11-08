select
  order_id,
  user_id,
  lower(status) as status,
  created_at,
  shipped_at,
  delivered_at,
  returned_at,
  num_of_item as num_items
from {{ source('thelook', 'orders') }}
where created_at < timestamp('{{ var("cutoff_date") }}')

-- Una riga d'ordine appartiene al periodo del suo ordine: entrano solo le righe
-- di ordini creati prima della data di taglio. Filtrare sulla data della riga
-- lasciava fuori alcuni ordini ma non le loro righe (test sui ricavi fallito).
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
where order_id in (
  select order_id
  from {{ source('thelook', 'orders') }}
  where created_at < timestamp('{{ var("cutoff_date") }}')
)

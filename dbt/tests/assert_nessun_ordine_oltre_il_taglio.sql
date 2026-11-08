-- Nessun ordine deve superare la data di taglio.
select order_id, order_date
from {{ ref('fct_orders') }}
where order_date >= date('{{ var("cutoff_date") }}')

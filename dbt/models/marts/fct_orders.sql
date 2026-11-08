with items as (
  select
    order_id,
    count(*) as items,
    sum(if(status != 'cancelled', sale_price, 0)) as gross_revenue,
    sum(if(status not in ('cancelled', 'returned'), sale_price, 0)) as net_revenue
  from {{ ref('stg_order_items') }}
  group by order_id
)

select
  o.order_id,
  o.user_id,
  date(o.created_at) as order_date,
  o.created_at,
  o.status,
  i.items,
  i.gross_revenue,
  i.net_revenue,
  -- Numero progressivo tra gli ordini non cancellati del cliente (1 = primo acquisto)
  if(o.status = 'cancelled', null,
     row_number() over (
       partition by o.user_id, o.status = 'cancelled'
       order by o.created_at, o.order_id
     )) as user_order_number,
  -- Mesi dal mese della coorte (0 = mese del primo acquisto)
  if(o.status = 'cancelled', null,
     date_diff(date_trunc(date(o.created_at), month), u.cohort_month, month)
  ) as months_since_first_order
from {{ ref('stg_orders') }} as o
left join items as i
  using (order_id)
left join {{ ref('dim_users') }} as u
  using (user_id)

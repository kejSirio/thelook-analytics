with first_orders as (
  select
    user_id,
    min(created_at) as first_order_at,
    count(*) as lifetime_orders
  from {{ ref('stg_orders') }}
  where status != 'cancelled'
  group by user_id
)

select
  u.user_id,
  u.age,
  u.gender,
  u.country,
  u.state,
  u.city,
  u.signup_source,
  coalesce(m.channel_group, 'Altro') as signup_channel,
  date(u.created_at) as signup_date,
  date(f.first_order_at) as first_order_date,
  date_trunc(date(f.first_order_at), month) as cohort_month,
  coalesce(f.lifetime_orders, 0) as lifetime_orders
from {{ ref('stg_users') }} as u
left join first_orders as f
  using (user_id)
left join {{ ref('channel_map') }} as m
  on u.signup_source = m.source_label

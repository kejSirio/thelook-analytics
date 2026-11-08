-- Una riga per sessione. Attenzione: in theLook il funnel segue regole
-- fisse del generatore (vedi README), non usarlo per conclusioni di business.
with sessions as (
  select
    session_id,
    max(user_id) as user_id,
    max(user_id) is not null as is_registered,
    min(created_at) as session_start,
    date(min(created_at)) as session_date,
    array_agg(session_source ignore nulls order by sequence_number limit 1)[safe_offset(0)] as session_source,
    array_agg(browser ignore nulls order by sequence_number limit 1)[safe_offset(0)] as browser,
    count(*) as events,
    countif(event_type = 'product') > 0 as viewed_product,
    countif(event_type = 'cart') > 0 as added_to_cart,
    countif(event_type = 'purchase') > 0 as purchased
  from {{ ref('stg_events') }}
  group by session_id
)

select
  s.*,
  coalesce(m.channel_group, 'Altro') as session_channel
from sessions as s
left join {{ ref('channel_map') }} as m
  on s.session_source = m.source_label

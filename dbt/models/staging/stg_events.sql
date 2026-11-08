-- Niente indirizzi IP: restano nella sorgente.
select
  id as event_id,
  user_id,
  session_id,
  sequence_number,
  created_at,
  browser,
  traffic_source as session_source,
  lower(event_type) as event_type,
  uri,
  state,
  city
from {{ source('thelook', 'events') }}
where created_at < timestamp('{{ var("cutoff_date") }}')

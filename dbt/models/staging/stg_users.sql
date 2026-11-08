-- Niente dati personali: nomi, email e indirizzi restano nella sorgente.
select
  id as user_id,
  age,
  gender,
  country,
  state,
  city,
  traffic_source as signup_source,
  created_at
from {{ source('thelook', 'users') }}
where created_at < timestamp('{{ var("cutoff_date") }}')

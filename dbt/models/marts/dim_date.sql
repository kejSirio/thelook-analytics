-- Calendario dal 2019 al giorno prima della data di taglio.
select
  d as date,
  extract(year from d) as year,
  extract(quarter from d) as quarter,
  extract(month from d) as month,
  date_trunc(d, month) as month_start,
  format_date('%Y-%m', d) as year_month,
  extract(isoweek from d) as iso_week,
  extract(dayofweek from d) as day_of_week,  -- 1 = domenica
  extract(dayofweek from d) in (1, 7) as is_weekend,
  date_trunc(d, month) < date_trunc(date('{{ var("cutoff_date") }}'), month) as is_complete_month
from unnest(generate_date_array(
  date '2019-01-01',
  date_sub(date('{{ var("cutoff_date") }}'), interval 1 day)
)) as d

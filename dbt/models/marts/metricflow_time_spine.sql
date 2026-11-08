-- Calendario richiesto da MetricFlow per le metriche nel tempo.
select d as date_day
from unnest(generate_date_array(date '2019-01-01', date '2030-12-31')) as d

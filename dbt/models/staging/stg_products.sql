select
  id as product_id,
  name as product_name,
  brand,
  category,
  department,
  cost,
  retail_price,
  distribution_center_id
from {{ source('thelook', 'products') }}

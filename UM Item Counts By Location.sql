select 
    locations.name as "Location",
    COALESCE(count(items.id),0) "Item Count"
from inventory.location__t as locations
left join
    inventory.item__t as items on
    locations.id = items.effective_location_id
where locations.name like 'UM%'
group by locations.name
order by "Item Count"
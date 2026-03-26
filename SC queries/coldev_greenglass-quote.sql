select
	count(distinct it2.id) as "title count",
	count(distinct it.id) as "item count"
from inventory.item__t it 
	left join inventory.material_type__t mtt on mtt.id = it.material_type_id 
	left join inventory.holdings_record__t hrt on hrt.id = it.holdings_record_id 
	left join inventory.instance__t it2 on it2.id = hrt.instance_id 
	left join inventory.mode_of_issuance__t moit on moit.id = it2.mode_of_issuance_id 
	left join inventory.location__t lt on lt.id = it.effective_location_id
where lt.library_id in ('f438535b-baaa-4977-adee-fd6cb2aeb03d', '5fdf6fab-5fcf-4363-9032-f8b3fec300b3')
	--and it.status__name in ('Awaiting pickup', 'In transit', 'Checked out', 'Available', 'Restricted', 'Paged')
	and moit."name" in ('Serial', 'Integrating Resource')
select count(distinct it2.id) as "43 Serials - physical (title count)"
from inventory.item__t it 
	left join inventory.material_type__t mtt on mtt.id = it.material_type_id 
	left join inventory.holdings_record__t hrt on hrt.id = it.holdings_record_id 
	left join inventory.instance__t it2 on it2.id = hrt.instance_id 
	left join inventory.location__t lt on lt.id = it.effective_location_id
where lt.campus_id in ('7d02e46d-3e60-4eaf-a986-5aa3550e8cb5' --Smith College
	, 'b23a14ae-b3a8-4cbf-92fb-4b81d1a4b0a1') --Five College Repository
	and it.status__name in ('Awaiting pickup', 'In transit', 'Checked out', 'Available', 'Restricted', 'Paged')
	and mtt.name in ('Journal', 'Newspaper', 'Serial')
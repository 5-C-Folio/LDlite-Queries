select distinct 
	count(distinct it2.id) as "Number of titles",
	count(distinct it.id) as "Number of items",
	ll."name" as "Library"
from inventory.item__t it
	left join inventory.location__t lt on it.effective_location_id = lt.id
	left join inventory.loclibrary__t ll on lt.library_id = ll.id
	left join inventory.holdings_record__t hrt on hrt.id = it.holdings_record_id 
	left join inventory.instance__t it2 on it2.id = hrt.instance_id 
where ll."name" = 'SC Annex'
	and (substring(it.metadata__created_date from 0 for 8) in ('2023-02', '2023-03', '2023-04', '2023-05', '2023-06', '2023-07', '2023-08', '2023-09')
		or substring(it.metadata__updated_date from 0 for 8) in ('2023-02', '2023-03', '2023-04', '2023-05', '2023-06', '2023-07', '2023-08', '2023-09'))
group by ll."name"
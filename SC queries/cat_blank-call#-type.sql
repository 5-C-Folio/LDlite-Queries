select
	it2.title,
	it2.hrid as "instance HRID",
	lt."name" as "effective location",
	it.effective_call_number_components__call_number as "call#",
	cntt.name as "call# type",
	it.barcode,
	it.status__name,
	it.status__date,
	case 
		when it2.discovery_suppress = true then 'No'
		when hrt.discovery_suppress = true then 'No'
		when it.discovery_suppress = true then 'No'
		when it2."source" = 'FOLIO' then 'No'
		else 'Yes'
	end "Does this item display in Discover?",
	mtt."name" as "material type"
from inventory.item__t it
	left join inventory.holdings_record__t hrt on hrt.id = it.holdings_record_id
	left join inventory.instance__t it2 on it2.id = hrt.instance_id 
	left join inventory.location__t lt on lt.id = it.effective_location_id
	left join inventory.call_number_type__t cntt on cntt.id = it.effective_call_number_components__type_id 
	left join inventory.material_type__t mtt on mtt.id = it.material_type_id 
where it.effective_call_number_components__type_id is null
	and it.status__name not in ('On order', 'In process')
	and it.effective_call_number_components__call_number is not null
order by
	lt."name" 
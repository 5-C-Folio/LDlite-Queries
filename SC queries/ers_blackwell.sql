select distinct
	it.hrid as "instance HRID",
	it.title,
	iti.identifiers__value as "OCN",
	lt."name" as "location",
	hrtea.hrid as "holdings HRID",
	hrtea.id as "holdings UUID",
	hrtea.electronic_access__uri,
	hrtea.electronic_access__link_text 
from inventory.holdings_record__t__electronic_access hrtea
	left join inventory.location__t lt on lt.id = hrtea.permanent_location_id 
	left join inventory.instance__t it on it.id = hrtea.instance_id 
	left join inventory.instance__t__identifiers iti on iti.id = it.id
	left join folio_source_record.marctab m on m.instance_id::varchar = it.id 
where lt."name" = 'SC Internet' 
	and iti.identifiers__identifier_type_id = '439bfbae-75bc-4f74-9fc7-b2a2d47ce3ef' --OCN
	and m.field = '730'
	and (hrtea.electronic_access__uri like '%blackwellreference%' or m."content" like '%Blackwell Reference Online%')
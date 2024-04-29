select
	hrt.id as "holdings UUID",
	hrt.hrid as "holdings HRID",
	lt."name" as "location",
	cntt."name" as "type",
	hrt.call_number_prefix as "prefix",
	hrt.call_number as "call#",
	hrt.call_number_suffix as "suffix",
	iti.index_title,
	iti.hrid as "instance HRID"
from inventory.instance__t__identifiers iti
	left join inventory.holdings_record__t hrt on hrt.instance_id = iti.id 
	left join inventory.location__t lt on lt.id = hrt.permanent_location_id 
	left join inventory.call_number_type__t cntt on cntt.id = hrt.call_number_type_id 
where iti.identifiers__value = '(SMISLKR)2051672'
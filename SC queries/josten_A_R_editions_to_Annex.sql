select
	it2.hrid as "instance HRID",
	it2.index_title,
	hrt.id as "holdings UUID",
	hrt.hrid as "holdings HRID",
	lt."name" as "location",
	hrt.call_number_prefix as "prefix",
	hrt.call_number as "call#",
	hrt.call_number_suffix as "suffix",
	it.id as "item UUID",
	it.barcode as "barcode",
	it.volume as "volume",
	it.copy_number as "copy",
	it.status__name as "status",
	it.status__date as "status date",
	mtt."name" as "material type",
	ltt."name" as "loan type"
from inventory.item__t it
	left join inventory.holdings_record__t hrt on it.holdings_record_id = hrt.id 
	left join inventory.location__t lt on lt.id = hrt.permanent_location_id 
	left join inventory.instance__t it2 on it2.id = hrt.instance_id 
	left join inventory.material_type__t mtt on mtt.id = it.material_type_id 
	left join inventory.loan_type__t ltt on ltt.id = it.permanent_loan_type_id 
where hrt.hrid in ('ho00002026180', 'ho00002026086', 'ho00003893729', 'ho00003857813', 'ho00002026186')
order by it2.hrid, it.volume 
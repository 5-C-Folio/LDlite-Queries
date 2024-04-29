select 
	it2.title,
	it2.discovery_suppress,
	it2.hrid as "instance HRID",
	lt."name" as "holdings location",
	hrt.call_number,
	it.barcode,
	it.volume,
	it.id as "item UUID",
	it.status__name as "status",
	ltt."name" as "loan type",
	hrt.id as "holdings UUID"
from inventory.item__t it 
	left join inventory.holdings_record__t hrt on hrt.id = it.holdings_record_id 
	left join inventory.instance__t it2 on it2.id = hrt.instance_id 
	left join inventory.loan_type__t ltt on ltt.id = it.permanent_loan_type_id 
	left join inventory.location__t lt on lt.id = hrt.permanent_location_id 
--where it.status__name = 'In process' and barcode like '%-SMT'
where hrt.id in (select hrt.id from inventory.item__t it left join inventory.holdings_record__t hrt on hrt.id = it.holdings_record_id where
	it.id in (select upload.item_uuids from public.sm_item_ar_uuids upload))
group by it2.title, it2.discovery_suppress, hrt.id, it2.hrid, lt."name", hrt.call_number, it.barcode, it.volume, it.id, it.status__name, ltt."name"
select 
	it.hrid,
	it.title,
	it.discovery_suppress,
	it.staff_suppress,
	sct."name" as "stat code",
	lt."name" as "holdings location"
from inventory.instance__t it
	left join inventory.instance__t__statistical_code_ids itsci on itsci.id = it.id
	left join inventory.statistical_code__t sct on sct.id = itsci.statistical_code_ids 
	left join inventory.holdings_record__t hrt on hrt.instance_id = it.id
	left join inventory.location__t lt on lt.id = hrt.effective_location_id 
where it.hrid in (
	select n.instance_hrid
	from folio_source_record.marctab n
	where n.field = '000'
	EXCEPT
	select m.instance_hrid
	from folio_source_record.marctab m
	where m.field = '008')
group by it.hrid, lt."name", it.title, it.discovery_suppress, it.staff_suppress, sct."name"
select 
	it2.title as "Title",
	lt2."name" as "Holdings location",
	lt."name" as "Effective location at loan",
	hrt.call_number as "Call number",
	it.barcode as "Barcode",
	coalesce(count(alt.id), 0) as "FOLIO circulations"
from inventory.item__t it 
	left join inventory.holdings_record__t hrt on it.holdings_record_id = hrt.id 
	left join inventory.instance__t it2 on hrt.instance_id = it2.id 
	left join circulation.audit_loan__t alt on alt.loan__item_id = it.id and alt.loan__action = 'checkedout'
	left join inventory.location__t lt on lt.id = alt.loan__item_effective_location_id_at_check_out 
	left join inventory.location__t lt2 on lt2.id = hrt.permanent_location_id 
	left join inventory.material_type__t mtt on mtt.id = it.material_type_id 
where lt."name" in ('SC Art Reserve', 'SC Art Open Reserve', 'SC Josten Reserve', 'SC Neilson Reserve Permanent', 'SC Neilson Reserve', 'SC Neilson Open Reserves')
	and mtt."name" <> 'Equipment'
group by 3,2,4,1,5
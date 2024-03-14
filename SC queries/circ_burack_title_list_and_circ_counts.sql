select
	it2.title as "Title",
	lt."name" as "Location",
	it.effective_call_number_components__call_number as "Call number",
	it.barcode as "Barcode",
	substring(it.effective_call_number_components__call_number, ' (\d{4})$') as "Call# year",
	coalesce(count(distinct alt.id), 0) as "FOLIO circulations",
	coalesce(itn.notes__note::bigint, 0) as "Aleph circulations",
	coalesce(coalesce(itn.notes__note::bigint, 0)+coalesce(count(distinct alt.id), 0),0) as "Total count"
from inventory.item__t it 
	left join inventory.item__t__notes itn on itn.id = it.id and itn.notes__item_note_type_id = 'f765f19f-9f1c-4688-8c79-ec366a730842'
	left join circulation.audit_loan__t alt on alt.loan__item_id = it.id and alt.loan__action = 'checkedout'
	left join inventory.location__t lt on lt.id = it.effective_location_id
	left join inventory.material_type__t mtt on mtt.id = it.material_type_id 
	left join inventory.holdings_record__t hrt on hrt.id = it.holdings_record_id 
	left join inventory.instance__t it2 on it2.id = hrt.instance_id 
where lt."name" = 'SC Neilson Burack'
group by 1,2,3,4,7,it.effective_shelving_order 
--having coalesce(coalesce(itn.notes__note::bigint, 0)+coalesce(count(distinct alt.id), 0),0) > 0
--order by coalesce(coalesce(itn.notes__note::bigint, 0)+coalesce(count(distinct alt.id), 0),0) desc
order by it.effective_shelving_order 
--limit 50
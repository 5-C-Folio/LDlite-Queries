select distinct
	it2.title as "Title",
	lt."name" as "Holdings location",
	lt2."name" as "Item effective location",
	hrt.call_number as "Call number",
	it.barcode as "Barcode",
	it.volume as "Volume",
	it.status__name as "Status",
	substring(it.status__date from 0 for 11) as "Status last update date",
	it.id as "Item UUID",
	itan.administrative_notes as "Admin note",
	itcn.circulation_notes__note as "Circ note",
	coalesce(count(alt.id), 0) as "FOLIO circulations",
	coalesce(itn.notes__note::bigint, 0) as "Aleph circulations",
	coalesce(coalesce(itn.notes__note::bigint, 0)+coalesce(count(alt.id), 0),0) as "Total circs"
from inventory.item__t it
	left join inventory.holdings_record__t hrt on it.holdings_record_id = hrt.id 
	left join inventory.instance__t it2 on hrt.instance_id = it2.id 
	left join inventory.location__t lt on hrt.permanent_location_id = lt.id 
	left join inventory.location__t lt2 on it.effective_location_id = lt2.id
	left join inventory.item__t__notes itn on itn.id = it.id and itn.notes__item_note_type_id = 'f765f19f-9f1c-4688-8c79-ec366a730842'  -- legacy circ count
	left join circulation.audit_loan__t alt on alt.loan__item_id = it.id and alt.loan__action = 'checkedout'  -- FOLIO circ count
	left join inventory.item__t__administrative_notes itan on itan.id = it.id 
	left join inventory.item__t__circulation_notes itcn on itcn.id = it.id
where it.status__name in ('Aged to lost', 'Claimed returned', 'Declared lost', 'Long missing', 'Lost and paid', 'Missing', 'Unknown', 'Withdrawn')
	and (lt.campus_id = '7d02e46d-3e60-4eaf-a986-5aa3550e8cb5' or lt2.campus_id = '7d02e46d-3e60-4eaf-a986-5aa3550e8cb5') -- Smith campus_id
	--and substring(it.status__date from 0 for 11)::date between '2023-07-01' and '2024-06-30'  -- remove dashes at the start of this line and update the dates to the range that you want to see
group by 1,2,3,4,5,6,7,8,9,10,11,itn.notes__note
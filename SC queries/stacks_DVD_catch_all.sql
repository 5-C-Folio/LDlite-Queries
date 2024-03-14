select
	it2.title as "Title",
	it2.hrid as "Instance HRID",
	lt."name" as "Holdings location",
	lt2."name" as "Item effective location",
	hrt.call_number as "Call number",
	hrt.id as "Holdings UUID",
	it.barcode as "Barcode",
	it.volume as "Volume",
	mtt."name" as "Material type",
	it.status__name as "Status",
	ltt."name" as "Loan type",
	case 
		when it2.discovery_suppress = true then 'No'
		when hrt.discovery_suppress = true then 'No'
		when it.discovery_suppress = true then 'No'
		when it2."source" = 'FOLIO' then 'No'
		else 'Yes'
	end "Does this item display in Discover?",
	it.id as "Item UUID",
	itcn.circulation_notes__note as "Check out note",
	itcn2.circulation_notes__note as "Check in note"
from inventory.item__t it
	left join inventory.holdings_record__t hrt on it.holdings_record_id = hrt.id 
	left join inventory.instance__t it2 on hrt.instance_id = it2.id 
	left join inventory.location__t lt on hrt.permanent_location_id = lt.id 
	left join inventory.location__t lt2 on it.effective_location_id = lt2.id
	left join inventory.loan_type__t ltt on it.permanent_loan_type_id = ltt.id 
	left join inventory.material_type__t mtt on it.material_type_id = mtt.id
	left join inventory.item__t__circulation_notes itcn on itcn.id = it.id and itcn.circulation_notes__note_type = 'Check out'
	left join inventory.item__t__circulation_notes itcn2 on itcn2.id = it.id and itcn2.circulation_notes__note_type = 'Check in'
where (lt."name" = 'SC Neilson DVD' or lt2."name" = 'SC Neilson DVD')
		--or (lt.campus_id = '7d02e46d-3e60-4eaf-a986-5aa3550e8cb5' and mtt."name" = 'DVD/Blu-ray')
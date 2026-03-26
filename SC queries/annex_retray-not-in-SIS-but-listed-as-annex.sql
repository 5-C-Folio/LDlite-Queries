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
	sss.status as "SIS status"
from inventory.item__t it
	left outer join public.sc_sis_snapshot sss on sss.barcode = it.barcode
	left join inventory.holdings_record__t hrt on it.holdings_record_id = hrt.id 
	left join inventory.instance__t it2 on hrt.instance_id = it2.id 
	left join inventory.location__t lt on hrt.permanent_location_id = lt.id 
	left join inventory.location__t lt2 on it.effective_location_id = lt2.id
	left join inventory.loan_type__t ltt on it.permanent_loan_type_id = ltt.id 
	left join inventory.material_type__t mtt on it.material_type_id = mtt.id
where lt2.library_id = '6bb6c83a-dd37-43dd-bf4d-bea653be401a'
	and it.status__name <> 'Checked out'
	and sss.barcode is null
	and it.barcode is not null
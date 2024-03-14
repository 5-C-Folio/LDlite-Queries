select
	it2.title as "Title",
	lt."name" as "Holdings location",
	lt2."name" as "Item effective location",
	hrt.call_number as "Call number",
	hrt.id as "Holdings UUID",
	it.barcode as "Barcode",
	it.volume as "Volume",
	it.status__name as "Status",
	ltt."name" as "Loan type",
	it.id as "Item UUID"
from inventory.item__t it
	left join inventory.holdings_record__t hrt on it.holdings_record_id = hrt.id 
	left join inventory.instance__t it2 on hrt.instance_id = it2.id 
	left join inventory.location__t lt on hrt.permanent_location_id = lt.id 
	left join inventory.location__t lt2 on it.effective_location_id = lt2.id
	left join inventory.loan_type__t ltt on it.permanent_loan_type_id = ltt.id 
where lt."name" in ('SC Art New Book Shelf', 'SC Josten New Book Shelf', 'SC Neilson New Book Shelf') or lt2."name" in ('SC Art New Book Shelf', 'SC Josten New Book Shelf', 'SC Neilson New Book Shelf')
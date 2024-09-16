select
	it2.hrid as "HRID",
	it2.title as "Title",
	lt."name" as "Holdings location",
	lt2."name" as "Item location",
	hrt.call_number as "Call number",
	it.volume as "Volume",
	it.barcode as "Barcode",
	it.copy_number as "Copy number",
	mtt."name" as "Material type",
	ltt."name" as "Loan type",
	coalesce(count(alt.id), 0) as "FOLIO circulations"
from inventory.item__t it 
	left join inventory.holdings_record__t hrt on hrt.id = it.holdings_record_id
	left join inventory.instance__t it2 on it2.id = hrt.instance_id
	left join inventory.location__t lt on lt.id = hrt.permanent_location_id
	left join inventory.location__t lt2 on lt2.id = it.effective_location_id
	left join inventory.material_type__t mtt on mtt.id = it.material_type_id
	left join inventory.loan_type__t ltt on ltt.id = it.permanent_loan_type_id
	left join circulation.audit_loan__t alt on alt.loan__item_id = it.id and alt.loan__action in ('checkedout', 'checkedOutThroughOverride', 'renewed', 'renewedThroughOverride')
where lt."name" in ('SC Art Locked Stack', 'SC Art Locked Stack Oversize') or lt2."name" in ('SC Art Locked Stack', 'SC Art Locked Stack Oversize')
group by 1,2,3,4,5,6,7,8,9,10
order by 3,5,6,8,2
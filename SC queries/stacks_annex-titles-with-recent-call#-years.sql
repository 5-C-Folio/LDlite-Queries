select
	it.barcode as "Barcode",
	it2.title as "Title",
	lt."name" as "Location",
	it.effective_call_number_components__call_number as "Call#",
	substring(it.effective_call_number_components__call_number, ' (\d{4})$') as "Call# year",
	coalesce(count(alt.id), 0) as "FOLIO circulations"
from inventory.item__t it
	inner join inventory.holdings_record__t hrt on hrt.id = it.holdings_record_id and hrt.effective_location_id in ('5eb79fcc-af08-4ae1-9ab3-dde11e330a01', 'ed12a1d9-33e7-4c62-8daf-485e7d2369c3')
	left join inventory.instance__t it2 on it2.id = hrt.instance_id
	left join inventory.location__t lt on lt.id = it.effective_location_id
	left join circulation.audit_loan__t alt on alt.loan__item_id = it.id and alt.loan__action in ('checkedout', 'checkedOutThroughOverride')
where it.status__name in ('Checked out', 'Awaiting pickup', 'In transit', 'Paged')
	and substring(it.effective_call_number_components__call_number, ' (\d{4})$') >= '2013'
group by 1,2,3,4,5
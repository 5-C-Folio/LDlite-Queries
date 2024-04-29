select
	it.hrid, 
	it.title,
	plt.po_line_number,
	string_agg(distinct lt."name", ', ') as "Location"
from folio_source_record.marctab m
	left join inventory.instance__t it on it.id::uuid = m.instance_id
	left join inventory.holdings_record__t hrt on hrt.instance_id = it.id 
	left join inventory.item__t it2 on it2.holdings_record_id = hrt.id
	left join inventory.location__t lt on lt.id = it2.effective_location_id
	left join orders.po_line__t plt on plt.instance_id = it.id 
	left join orders.purchase_order__t pot on pot.id = plt.purchase_order_id 
where ((m.field = '008' and substring(m."content" from 36 for 3) = 'ger')
	or (m.field = '041' and m.sf = 'a' and m.content = 'ger'))
	-- ^ the 008 field lang code is German or there is a 041$a for German
	and (lt.campus_id = '7d02e46d-3e60-4eaf-a986-5aa3550e8cb5' and lt.code <> 'SCINT') --Smith, but not online
	and (pot.workflow_status = 'Open' and pot.po_number_prefix = 'SC' and pot.order_type = 'Ongoing')  --open, ongoing Smith orders
group by 1, 2, 3
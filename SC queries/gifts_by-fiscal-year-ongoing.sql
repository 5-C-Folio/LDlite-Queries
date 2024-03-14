select 
	it2.title as "Title",
	plt.description as "Note",
	lt."name" as "Location",
	hrt.call_number as "Call number",
	count(distinct it.hrid) as "Number of issues",
	mtt."name" as "Format"
from inventory.item__t it 
	left join orders.pieces__t pt on it.id = pt.item_id
	left join orders.po_line__t plt on plt.id = pt.po_line_id 
	left join orders.purchase_order__t__acq_unit_ids potaui on potaui.id = plt.purchase_order_id
	left join inventory.holdings_record__t hrt on hrt.id = it.holdings_record_id 
	left join inventory.instance__t it2 on it2.id = hrt.instance_id 
	left join inventory.location__t lt on it.effective_location_id = lt.id
	left join inventory.material_type__t mtt on it.material_type_id = mtt.id 
where plt.acquisition_method = '0a4163a5-d225-4007-ad90-2fb41b73efab' --gift
	and potaui.acq_unit_ids = 'b17b9e6b-82bb-4f97-b3e7-757e4e5aeb61'  --SC
	and cast(substring(it.metadata__created_date, 0, 11) as date) between '2022-07-01' and '2023-06-30'
group by hrt.call_number, it2.title, lt.name, mtt.name, plt.description 
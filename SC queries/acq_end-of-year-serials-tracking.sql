select distinct
	plt.po_line_number as "POL #",
	plt.title_or_package as "Title or Package",
	potaui.workflow_status as "PO Status", 
	plt.cost__po_line_estimated_price as "POL Estimated Price",
	coalesce(payment, '0') as "Sum of Invoice Payments",
	ft."name" as "Fund Name",
	plt.cost__po_line_estimated_price - coalesce(payment, '0') as "Delta"
from orders.po_line__t plt 
--
inner join orders.purchase_order__t__acq_unit_ids potaui on plt.purchase_order_id = potaui.id
	and potaui.acq_unit_ids = 'b17b9e6b-82bb-4f97-b3e7-757e4e5aeb61'  --ACQ unit of SC
	and potaui.order_type = 'Ongoing'
--
left join (
	select sum(ilt.total) as payment, po_line_id
	from invoice.invoice_lines__t ilt 
	--inner join invoice.invoices__t it on it.id = ilt.invoice_id and it.payment_date between '2021-07-01' and '2022-06-30' --FY22
	--inner join invoice.invoices__t it on it.id = ilt.invoice_id and it.payment_date between '2022-07-01' and '2023-06-30' --FY23
	inner join invoice.invoices__t it on it.id = ilt.invoice_id and it.payment_date between '2023-07-01' and '2024-06-30' --FY24
	where ilt.invoice_line_status = 'Paid'
	group by po_line_id
	) as i
on
	plt.id = i.po_line_id
--
left join orders.po_line__t__fund_distribution pltfd on pltfd.id = plt.id 
left join finance.fund__t ft on ft.id = pltfd.fund_distribution__fund_id 
--
/*
where plt.po_line_number ='SC90195-1' --two payments in one year
	or plt.po_line_number ='SC1209822X-1' --one payment this FY, one last year
	or plt.po_line_number ='SC59673-1'  --no payments
*/
order by plt.cost__po_line_estimated_price - coalesce(payment, '0') desc, coalesce(payment, '0') desc
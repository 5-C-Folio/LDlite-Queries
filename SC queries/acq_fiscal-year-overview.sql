select
	plt.po_line_number as "POL #",
	plt.title_or_package as "Title or Package",
	plt.order_format as "POL format",
	coalesce(mtte."name", mttp."name", '') as "Material Type",
	potaui.workflow_status as "PO Status",
	potaui.order_type as "PO Type",
	inv.payment as "Sum of Invoice Payments",
	inv.fund as "Fund name"
from orders.po_line__t plt 
	inner join orders.purchase_order__t__acq_unit_ids potaui on (plt.purchase_order_id = potaui.id and potaui.acq_unit_ids = 'b17b9e6b-82bb-4f97-b3e7-757e4e5aeb61')  --ACQ unit of SC
	inner join (
		select sum(iltfd.total * (iltfd.fund_distributions__value * .01)) as payment, po_line_id, ftaui."name" as fund
		from invoice.invoice_lines__t__fund_distributions iltfd  
			inner join invoice.invoices__t it on it.id = iltfd.invoice_id and cast(substring(it.payment_date, 0, 11) as date) between '2022-07-01' and '2023-07-15'
			left join finance.fund__t__acq_unit_ids ftaui on iltfd.fund_distributions__fund_id = ftaui.id
		where iltfd.invoice_line_status = 'Paid'
		group by po_line_id, ftaui."name" 
		) as inv
			on plt.id = inv.po_line_id
	left join inventory.material_type__t mtte on mtte.id = plt.eresource__material_type
	left join inventory.material_type__t mttp on mttp.id = plt.physical__material_type 
--where plt.po_line_number in ('SC108082-1', 'SC108621-1', 'SC58679-2')
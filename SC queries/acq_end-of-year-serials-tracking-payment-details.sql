select distinct
	plt.po_line_number as "POL #",
	plt.title_or_package as "Title or Package",
	potaui.workflow_status as "PO Status",
	ft."name" as "Current POL Fund Name",
	iltfd.total as "Payment",
	it.payment_date::date as "Payment date",
	ft2."name" as "Payment Fund Name",
	regexp_replace(plt.description , E'[\\n\\r]+', ' ', 'g' ) as "POL Internal Note"
from orders.po_line__t plt 
--
inner join orders.purchase_order__t__acq_unit_ids potaui on plt.purchase_order_id = potaui.id
	and potaui.acq_unit_ids = 'b17b9e6b-82bb-4f97-b3e7-757e4e5aeb61'  --ACQ unit of SC
	and potaui.order_type = 'Ongoing'
left join invoice.invoice_lines__t__fund_distributions iltfd on plt.id = iltfd.po_line_id and iltfd.invoice_line_status = 'Paid'
left join invoice.invoices__t it on it.id = iltfd.invoice_id
left join orders.po_line__t__fund_distribution pltfd on pltfd.id = plt.id 
left join finance.fund__t ft on ft.id = pltfd.fund_distribution__fund_id
left join finance.fund__t ft2 on ft2.id = iltfd.fund_distributions__fund_id
/*
where plt.po_line_number ='SC90195-1' --two payments in one year
	or plt.po_line_number ='SC1209822X-1' --one payment this FY, one last year
	or plt.po_line_number ='SC59673-1'  --no payments
	or plt.po_line_number = 'SC108970-1'
*/
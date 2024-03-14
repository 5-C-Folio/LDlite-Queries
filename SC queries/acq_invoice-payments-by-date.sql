select
	plt.po_line_number as "POL number",
	plt.title_or_package as "POL title",
	substring(it.payment_date from 0 for 11) as "Invoice payment date",
	it.vendor_invoice_no as "Vendor invoice number",
	ilt.invoice_line_number as "Invoice line number",
	ilt.total as "Invoice line total"
from invoice.invoices__t it
	left join invoice.invoice_lines__t ilt on it.id = ilt.invoice_id
	left join orders.po_line__t plt on ilt.po_line_id = plt.id 
where (substring(it.payment_date from 0 for 10) like '2023-05%' or substring(it.payment_date from 0 for 10) like '2023-06%')
	and plt.po_line_number like 'SC%'
order by substring(it.payment_date from 0 for 11), it.vendor_invoice_no, cast(ilt.invoice_line_number as int)
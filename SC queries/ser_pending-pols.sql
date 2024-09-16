select
	plt.po_line_number,
	plt.title_or_package,
	ot."name" as "PO vendor",
	plt.description as "Internal note",
	plt.metadata__updated_date::date as "last updated"
from orders.po_line__t plt 
	left join orders.purchase_order__t pot on pot.id = plt.purchase_order_id 
	left join organizations.organizations__t ot on ot.id = pot.vendor 
where pot.po_number_prefix = 'SC'
	and plt.payment_status = 'Pending'
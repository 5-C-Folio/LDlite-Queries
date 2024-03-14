select 
	pot.po_number,
	pot.order_type,
	pot.workflow_status,
	pot.ongoing__is_subscription,
	pot.ongoing__manual_renewal,
	pot.ongoing__interval,
	pot.ongoing__renewal_date,
	pot.ongoing__review_period
from orders.purchase_order__t pot
where pot.po_number_prefix ='SC' and pot.order_type = 'Ongoing'
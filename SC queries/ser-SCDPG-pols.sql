select distinct 
	pltfd.title_or_package,
	pltfd.po_line_number,
	pot.workflow_status,
	ft.code,
	ft."name" as "fund",
	ect."name" as "expense class",
	pot.ongoing__is_subscription
from orders.po_line__t__fund_distribution pltfd
	left join orders.purchase_order__t pot on pot.id = pltfd.purchase_order_id
	left join finance.fund__t ft on ft.id = pltfd.fund_distribution__fund_id
	left join finance.expense_class__t ect on ect.id = pltfd.fund_distribution__expense_class_id 
where --((pot.workflow_status <> 'Closed' and ft.code = 'SCRPG' and pot.ongoing__is_subscription = false)
	--or (pot.workflow_status <> 'Closed' and ft.code = 'SCDPG'))
	pltfd.po_line_number in ('SC13115261-1', 'SC1108408X-1', 'SC12859199-1', 'SC13105528-1', 'SC1163604X-1')
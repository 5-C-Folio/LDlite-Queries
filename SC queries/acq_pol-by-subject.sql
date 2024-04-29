select distinct
	its.hrid,
	its.index_title,
	plt.po_line_number,
	coalesce(payment, plt.cost__po_line_estimated_price) as "paid or estimated price"
	--its.subjects
from inventory.instance__t__subjects its
	inner join orders.po_line__t plt on plt.instance_id = its.id 
	inner join orders.purchase_order__t__acq_unit_ids potaui on potaui.id = plt.purchase_order_id
	left join (
		select sum(total) as payment, po_line_id
		from invoice.invoice_lines__t ilt 
		where ilt.invoice_line_status = 'Paid'
		group by po_line_id
		) as i
			on plt.id = i.po_line_id
where
	potaui.acq_unit_ids = 'b17b9e6b-82bb-4f97-b3e7-757e4e5aeb61' --Acq unit of SC
	and plt.po_line_number not in ('SC67447-1', 'SC83765-1', 'SC136728-1')
	and its.subjects in (
		'Handicraft',
		'Handicraft--United States--History',
		'Indian handicraft industries',
		'Indian handicraft industries--United States--History--20th century',
		'Textile crafts',
		'Textile crafts--Exhibitions',
		'Hand weaving',
		'Hand weaving--United States',
		'Navajo women weavers--Social conditions--20th century',
		'Weaving',
		'Weaving--United States',
		'Women weavers',
		'Women weavers--United States',
		'Basket making--Four Corners Region--Antiquities',
		'Dressmaking',
		'Dressmaking Periodicals',
		'Fiberwork',
		'Fiberwork--Exhibitions',
		'Folk art',
		'Folk art--United States--Periodicals',
		'ART / Folk Art',
		'ART / Indigenous Art of the Americas',
		'ART / Women Artists',
		'Clothing and dress',
		'Clothing and dress Databases',
		'Clothing and dress History Periodicals',
		'Clothing and dress in art',
		'Clothing and dress in art--Exhibitions',
		'Clothing and dress Periodicals',
		'Clothing and dress Social aspects Periodicals',
		'Clothing and dress United States History Periodicals',
		'Clothing and dress United States Periodicals',
		'Clothing and dress--Law and legislation',
		'Clothing and dress--Law and legislation--History',
		'Clothing and dress--Middle East',
		'Clothing and dress--Social aspects',
		'Clothing and dress--Social aspects--History',
		'Clothing and dress--Social aspects--New Spain--Exhibitions',
		'Clothing and dress--Symbolic aspects',
		'Clothing and dress--Symbolic aspects--Pictorial works'
		)
	
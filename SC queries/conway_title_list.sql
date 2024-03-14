select  instance__t.title, item__t.effective_call_number_components__call_number as callnumber, item__t.barcode, item__t.status__name as status
from inventory.item__t
left join inventory.holdings_record__t on item__t.holdings_record_id = holdings_record__t.id
left join inventory.instance__t on holdings_record__t.instance_id = instance__t.id
where item__t.effective_location_id = 'c18c7874-ff84-433f-b7d3-b6de4fe4578e'
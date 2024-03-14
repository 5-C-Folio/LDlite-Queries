select
	it2.title,
	lt."name" as "effective location",
	hrt.call_number,
	hrt.hrid 
from inventory.item__t it 
	left join inventory.holdings_record__t hrt on hrt.id = it.holdings_record_id 
    left join inventory.location__t as lt on hrt.effective_location_id = lt.id
    left join inventory.instance__t it2 on it2.id = hrt.instance_id 
where (hrt.call_number like E'%\n%' or hrt.call_number like E'%\r%')
	--and it.barcode = '310183610887001'
group by lt.name, hrt.hrid, hrt.call_number, it2.title
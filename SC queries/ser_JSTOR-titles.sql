select
	it.title as "Title",
	it.hrid as "Instance HRID",
	lt."name" as "Location"--,
	--itn.notes__note as "Note"
from inventory.item__t__notes itn
	left join inventory.holdings_record__t hrt on hrt.id = itn.holdings_record_id
	left join inventory.location__t lt on hrt.permanent_location_id = lt.id
	left join inventory.instance__t it on hrt.instance_id = it.id 
where upper(itn.notes__note) like '%JSTOR%' 
	and lt.campus_id = '7d02e46d-3e60-4eaf-a986-5aa3550e8cb5'  --Smith campus
group by it.title, it.hrid, lt."name" 
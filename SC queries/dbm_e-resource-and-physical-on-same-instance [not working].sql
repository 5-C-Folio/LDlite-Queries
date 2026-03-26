select 
	it.hrid,
	string_agg(distinct lt."name", ', ') as "holdings locations"
from inventory.holdings_record__t hrt 
	left join inventory.instance__t it on it.id = hrt.instance_id 
	left join inventory.holdings_record__t__electronic_access hrtea on hrtea.id = hrt.id
	left join inventory.location__t lt on lt.id = hrt.effective_location_id
where 
	it.id in (
		select hrtea2.instance_id
		from inventory.holdings_record__t__electronic_access hrtea2 
			left join inventory.electronic_access_relationship__t eart on eart.id = hrtea2.electronic_access__relationship_id
		where eart.name = 'Resource'
		)
	and 
	it.id in (
		select hrt2.instance_id
		from inventory.holdings_record__t hrt2
		where hrt2.id not in (
			select hrtea3.id
			from inventory.holdings_record__t__electronic_access hrtea3
				left join inventory.electronic_access_relationship__t eart2 on eart2.id = hrtea3.electronic_access__relationship_id
			where eart2.name = 'Resource'
			)
		)
group by 1
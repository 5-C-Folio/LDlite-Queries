select distinct 
	it2.hrid as "instance HRID",
	regexp_replace(it2.index_title , E'[\\n\\r]+', ' ', 'g' ) as "title",
	hrt.id as "holdings UUID",
	string_agg(distinct lt."name", ', ') as "holdings locations",
	eart."name" as "link type",
	regexp_replace(hrtea.electronic_access__uri, E'[\\n\\r]+', ' ', 'g' ) as "link",
	coalesce(count(distinct it.id), 0) as "items on title"
from inventory.holdings_record__t hrt
	left join inventory.holdings_record__t__electronic_access hrtea on hrtea.id = hrt.id
	left join inventory.electronic_access_relationship__t eart on eart.id = hrtea.electronic_access__relationship_id 
	left join inventory.instance__t it2 on it2.id = hrt.instance_id 
	left join inventory.location__t lt on lt.id = hrt.effective_location_id 
	left join inventory.item__t it on it.holdings_record_id = hrt.id
where hrtea.electronic_access__uri like 'http://www.fivecolleges.edu/libraries/depository/forms/request_article'
	and eart."name" <> 'No information provided'
group by 1,2,3,5,6
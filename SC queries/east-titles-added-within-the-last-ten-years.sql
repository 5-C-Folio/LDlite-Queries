select distinct m.srs_id,
	m.instance_hrid,
	m.instance_id as "instance UUID",
	--substring(m."content" from 7 for 1) as "Type of date",
	substring(m."content" from 8 for 4) as "Date 1",
	substring(m."content" from 12 for 4) as "Date 2",
	it2.index_title as "title",
	lt."name" 
from inventory.item__t it 
	left join inventory.holdings_record__t hrt on hrt.id = it.holdings_record_id
	left join inventory.instance__t it2 on it2.id = hrt.instance_id
	left join inventory.location__t lt on lt.id = hrt.permanent_location_id 
	left join folio_source_record.marctab m on cast(m.instance_id as varchar) = it2.id
where m.field = '008'
	and lt.code in ('ACDPM', 'ACDEP', 'AFRST')
	and ((substring(m."content" from 8 for 4) between '2011' and '2021') or (substring(m."content" from 12 for 4) between '2011' and '2021'))
select distinct
	it2.hrid as "instance HRID",
	it2.id as "instance UUID",
	regexp_replace(it2.index_title , E'[\\n\\r]+', ' ', 'g' ) as "title",
	regexp_replace(m.content, E'[\\n\\r]+', ' ', 'g' ) as "marc 856",
	lt."name" as "holdings location",
	regexp_replace(hrtea.electronic_access__uri, E'[\\n\\r]+', ' ', 'g' ) as "holdings uri"
from inventory.item__t it 
	left join inventory.holdings_record__t hrt on hrt.id = it.holdings_record_id 
	left join inventory.holdings_record__t__electronic_access hrtea on hrtea.id = hrt.id
	left join inventory.instance__t it2 on it2.id = hrt.instance_id
	left join folio_source_record.marctab m on m.instance_id::varchar = it2.id and m.field = '856'
		and m.ind1 = '4' and m.ind2 = '0' and m.sf = 'u'
	left join inventory.location__t lt on lt.id = hrt.effective_location_id
where regexp_replace(m.content, E'[\\n\\r]+', ' ', 'g' ) <> regexp_replace(hrtea.electronic_access__uri, E'[\\n\\r]+', ' ', 'g' )
select distinct
	it.barcode,
	it.id as "item UUID",
	ltt."name" as "loan type", 
	mtt."name" as "material type", 
	it.status__name,
	it.metadata__created_date as "item created date",
	lt."name" as "location", 
	--m2.field,
	--m2.ind1,
	--m2.ind2,
	--m2.sf,
	--m2.content,
	regexp_replace(hrtea.electronic_access__uri, E'[\\n\\r]+', ' ', 'g' ),
	it2.hrid as "instance HRID",
	regexp_replace(it2.index_title , E'[\\n\\r]+', ' ', 'g' )
from inventory.item__t it 
	left join inventory.holdings_record__t hrt on hrt.id = it.holdings_record_id 
	left join inventory.holdings_record__t__electronic_access hrtea on hrtea.id = hrt.id 
	left join inventory.instance__t it2 on it2.id = hrt.instance_id 
	left join inventory.location__t lt on lt.id = it.effective_location_id 
	left join inventory.material_type__t mtt on mtt.id = it.material_type_id 
	left join inventory.loan_type__t ltt on ltt.id = it.permanent_loan_type_id 
	left join folio_source_record.marctab m2 on m2.instance_id::varchar = it2.id and m2.field = '655' and m2.sf = 'a'
where lt."name" = 'SC Internet'
	--and it.barcode in ('15588715-10-SMT', 'B1622923-SMT', 'B1725068-SMT', 'B(FCEEBO)2240879055-SC', 'B1539196-UMA')
	and it2.discovery_suppress is false
	and it2.id not in (
		select m.instance_id::varchar
		from folio_source_record.marctab m
		where m.field = '655' and m.sf = 'a'
			and (m.content like 'Electronic books%' or m.content like 'Audiobooks%' or m.content like 'Streaming videos%' 
				or m.content like 'Streaming audios%' or m.content like 'Electronic journals%' 
				or m.content like 'Electronic maps%' or m.content like 'Electronic theses%' 
				or m.content like 'Electronic scores%' or m.content like 'Newspapers%')
			and m.instance_id::varchar in (
				select it2b.id
				from inventory.item__t itb
					left join inventory.holdings_record__t hrtb on hrtb.id = itb.holdings_record_id 
					left join inventory.instance__t it2b on it2b.id = hrtb.instance_id 
					left join inventory.location__t ltb on ltb.id = itb.effective_location_id 
				where ltb."name" = 'SC Internet'))	
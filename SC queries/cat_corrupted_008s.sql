select distinct m.srs_id,
	m.instance_hrid,
	m.instance_id as "instance UUID",
	case 
		when substring(m2."content" from 7 for 1) in ('a', 't') and substring(m2."content" from 8 for 1) in ('a', 'c', 'd', 'm') then 'Books'
		when substring(m2."content" from 7 for 1) = 'm' then 'Computer Files'
		when substring(m2."content" from 7 for 1) in ('e', 'f') then 'Maps'
		when substring(m2."content" from 7 for 1) in ('c', 'd', 'i', 'j') then 'Music'
		when substring(m2."content" from 7 for 1) = 'a' and substring(m2."content" from 8 for 1) in ('b', 'i', 's') then 'Continuing Resources'
		when substring(m2."content" from 7 for 1) in ('g', 'k', 'o', 'r') then 'Visual Materials'
		when substring(m2."content" from 7 for 1) = 'p' then 'Mixed Materials'
		else substring(m2."content" from 7 for 1)
	end as "type of record",
	m."content" as "008 field",
	substring(m."content" from 0 for 6) as "Date entered on file",
	substring(m."content" from 7 for 1) as "Type of date/Publication status",
	substring(m."content" from 8 for 4) as "Date 1",
	substring(m."content" from 12 for 4) as "Date 2",
	substring(m."content" from 16 for 3) as "Place of publication, production, or execution",
	substring(m."content" from 19 for 17) as "The stuff in the middle",
	substring(m."content" from 36 for 3) as "Language",
	substring(m."content" from 39 for 1) as "Modified record",
	substring(m."content" from 40 for 1) as "Cataloging source",
	it.index_title as "title",
	string_agg(distinct substring(lt."name" from 1 for 2), ', ') as "campus"
from folio_source_record.marctab m 
	left join inventory.instance__t it on it.id = cast(m.instance_id as varchar)
	left join inventory.holdings_record__t hrt on hrt.instance_id = it.id
	left join inventory.location__t lt on lt.id = hrt.permanent_location_id 
	left join folio_source_record.marctab m2 on m.srs_id = m2.srs_id
where m.field = '008'
	and m."content" like '%%'  --causes title to not be exported to EDS
	--and m."content" like '%̂%'  --can't edit record in quickMARC - seems to be in nature of contents pos?
	and m2.field = '000'
group by m.srs_id, m.instance_hrid, m2."content", m.instance_id, m."content", it.index_title
--Draft Rapid ILL Serial Holdings Report
select
	string_agg(idents.name || ': ' || instances.identifiers__value, ', ') as "Standard Numbers",
	string_agg(distinct instances.title::text, 'NEXT') as "Title",
	string_agg(distinct locations.name::text, 'NEXT' ) as "Location",
	string_agg(distinct locations.code::text, 'NEXT') as "Location Code",
	string_agg(distinct holdings.call_number::text, 'NEXT') as "Call Number",
	string_agg(distinct statements.holdings_statements__statement::text, ', ') as "Holdings Statement"
	--string_agg(distinct mat_type."name", ' ') as "Material Type"
from
	inventory.holdings_record__t as holdings
join inventory.holdings_record__t__holdings_statements as statements on
	holdings.id = statements.id
join inventory.instance__t__identifiers as instances on
	holdings.instance_id = instances.id
join inventory.location__t as locations on
	holdings.effective_location_id = locations.id
join inventory.identifier_type__t as idents on
	idents.id = instances.identifiers__identifier_type_id
join inventory.item__t as items on
	items.holdings_record_id = holdings.id
join inventory.material_type__t as mat_type on
	items.material_type_id = mat_type.id
where
	true
	and idents.name in ('OCLC', 'ISSN', 'ISBN')
	and mat_type.name in ('Journal')
	and locations.code in ('UEA', 'UMGEN', 'UJUV', 'UNEA', 'UMPER', 'UMLLR', 'USPC', 'UMSTOR')
group by holdings.id

-- Active: 1666295278584@@reportingtest.ddns.umass.edu@6991@ldplite
-- UM Rapid Physical Serials Lendable
select
	string_agg(distinct instances.title::text, 'NEXT') as "Title",
	string_agg(distinct locations.name::text, 'NEXT' ) as "Location",
	string_agg(distinct locations.code::text, 'NEXT') as "Location Code",
	string_agg(distinct holdings.call_number::text, 'NEXT') as "Call Number",
	string_agg(distinct oclc.oclc_val::text, ', ') as "OCLC Number(s)",
	string_agg(distinct issn.issn_val::text, ', ') as "ISSN(s)",
	string_agg(distinct isbn.isbn_val::text, ', ') as "ISBN(s)",
	string_agg(distinct statements.holdings_statements__statement::text, ', ') as "Holdings Statement"
	--string_agg(distinct mat_type.name::text, ', ')

from
	inventory.holdings_record__t as holdings
join inventory.holdings_record__t__holdings_statements as statements on
	holdings.id = statements.id
join inventory.instance__t__identifiers as instances on
	holdings.instance_id = instances.id
join inventory.location__t as locations on
	holdings.effective_location_id = locations.id
join inventory.item__t as items on
	items.holdings_record_id = holdings.id
join inventory.material_type__t as mat_type on
	items.material_type_id = mat_type.id
left join (
	select inst.identifiers__value as oclc_val, inst.id as inst_id from inventory.instance__t__identifiers as inst 
	join inventory.identifier_type__t as ident on inst.identifiers__identifier_type_id = ident.id 
	where ident."name" = 'OCLC' 
) as oclc on instances.id = oclc.inst_id
left join (
	select inst.identifiers__value as issn_val, inst.id as inst_id from inventory.instance__t__identifiers as inst 
	join inventory.identifier_type__t as ident on inst.identifiers__identifier_type_id = ident.id 
	where ident."name" = 'ISSN' 
) as issn on instances.id = issn.inst_id
left join (
	select inst.identifiers__value as isbn_val, inst.id as inst_id from inventory.instance__t__identifiers as inst 
	join inventory.identifier_type__t as ident on inst.identifiers__identifier_type_id = ident.id 
	where ident."name" = 'ISBN' 
) as isbn on instances.id = isbn.inst_id
where
	true
	and (oclc.oclc_val is not Null OR issn.issn_val is not Null OR isbn.isbn_val is not Null)
	and statements.holdings_statements__statement is not NULL
	and mat_type.name in ('Journal', 'Newspaper', 'Microform', 'Serial')
	and locations.code like 'UM%'
group by holdings.id

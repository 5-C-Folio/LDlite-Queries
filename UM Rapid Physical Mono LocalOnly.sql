-- Active: 1666295278584@@reportingtest.ddns.umass.edu@6991
-- UM Rapid Physical Mono Local Only
select
	
	string_agg(distinct instances.title::text, '') as "Title",
	string_agg(distinct locations.name::text, '') as "Location",
	string_agg(distinct locations.code::text, '') as "Location Code",
	string_agg(distinct holdings.call_number::text, '') as "Call Number",
	string_agg(distinct oclc.oclc_val::text, ', ') as "OCLC Number(s)",
	string_agg(distinct issn.issn_val::text, ', ') as "ISSN(s)",
	string_agg(distinct isbn.isbn_val::text, ', ') as "ISBN(s)"
	--string_agg(distinct mat_type.name::text, ', ')
	--string_agg(distinct statements.holdings_statements__statement::text, ', ') as "Holdings Statement",
	--string_agg(distinct mat_type."name", ' ') as "Material Type"
from
	inventory.holdings_record__t as holdings
--join inventory.holdings_record__t__holdings_statements as statements on
--	holdings.id = statements.id
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
	and (
			(mat_type.name in ('Supplement', 'Film') and locations.code like 'UM%')
			or
			(mat_type.name not in ('Journal', 'Newspaper')
			and locations.code in ( 'AFRNX', 'ACBD', 'AFRXX', 'ACFPS', 'AFMED', 'ACNBS', 'AFRX', 'AFRST', 'AMUS', 'HCDIS', 'HDVD', 'HCNBS', 'MMCUT', 'MMDSP', 'MMFAC', 'MDHON', 'MLEIF', 'MLEIB', 'MLRC', 'MLRCF', 'MDMST', 'MMVID', 'MMAUC', 'MMAUS', 'MMIC', 'MMNWB', 'MPMCD', 'MPRAT', 'MPVID', 'MMAIN', 'MMSTM', 'SXSTK', 'SXSTL', 'SXTHE', 'SASTK', 'SCADI', 'SCANB'))	
		)
group by holdings.id
--Hathi Trust Single Part Monographs
select 
	--oclc		-- REQUIRED
	substring(substring(string_agg(distinct identifiers.identifiers__value, ','),8) from '[0-9]*') as "oclc",
	--local_id  -- REQUIRED
	items.hrid as "local_id",
	--status	-- OPTIONAL
	case
		when string_agg(distinct items.status__name, '') = 'Withdrawn' then 'WD'
		when string_agg(distinct items.status__name, '') in ('Unavailable', 'Unknown', 'Order closed', 'On order') then ''
		when string_agg(distinct items.status__name, '') in ('Aged to lost', 'Declared lost', 'Missing', 'Long missing', 'Lost and paid', 'Claimed returned') then 'LM'
		else 'CH'
		end as "status"
	--condition -- OPTIONAL
	--enum_chron -- NA
	--issn -- NA
	--gov_doc   -- OPTIONAL
from 
	inventory.item__t as items
join
	inventory.holdings_record__t as holdings on 
	holdings.id = items.holdings_record_id 
join
	inventory.instance__t as instances on
	instances.id = holdings.instance_id 
join 
	inventory.instance__t__identifiers as identifiers on
	identifiers.id = instances.id
join
	inventory.location__t as locations on 
	locations.id = holdings.effective_location_id
where substring(locations.code, 0, 2) = 'U'
and identifiers.identifiers__identifier_type_id = '439bfbae-75bc-4f74-9fc7-b2a2d47ce3ef' --OCLC
and not(items.chronology is not null or items.enumeration is not null or items.volume is not null)
and items.material_type_id = '2d72aa13-2451-41fe-afc7-b3dc7c131389'
group by "local_id"
--Hathi Trust Multi Part Monographs
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
		end as "status",
	--condition -- OPTIONAL
	--enum_chron -- REQUIRED
	coalesce(string_agg(distinct items.enumeration, ''), '') || ' ' || coalesce(string_agg(distinct items.chronology, ''), '') || ' ' || coalesce(string_agg(distinct items.volume, ''), '') as "enum_chron"
	--coalesce(string_agg(distinct items.enumeration, ''), '') as enum, 
	--coalesce(string_agg(distinct items.chronology, ''), '') as chron,
	--coalesce(string_agg(distinct items.volume, ''), '') as vol
	--issn -- NA
	--gov_doc   -- OPTIONAL
from 
	inventory.item__t as items
left join
	inventory.item_damaged_status__t as conditions on
	conditions.id = items.item_damaged_status_id 
join
	inventory.holdings_record__t as holdings on 
	holdings.id = items.holdings_record_id 
join
	inventory.instance__t as instances on
	instances.id = holdings.instance_id 
join 
	inventory.instance__t__identifiers as identifiers on
	identifiers.id = instances.id
left join
	(select * from inventory.location__t where substring(location__t.code, 0, 2) = 'U') as locations on 
	locations.id = holdings.effective_location_id
where locations.code is not null 
and identifiers.identifiers__identifier_type_id = '439bfbae-75bc-4f74-9fc7-b2a2d47ce3ef' --OCLC
and items.material_type_id = '2d72aa13-2451-41fe-afc7-b3dc7c131389' --Book
and (items.enumeration is not null or items.chronology is not null or items.volume is not null)
group by "local_id"
--Hathi Trust Serials
select 
	--oclc		-- REQUIRED
	distinct 
	holdings.hrid as "local_id",
	case
		when substring(substring(string_agg(distinct identifiers.identifiers__value, ','),8) from '[0-9]*') != '' 
		then substring(substring(string_agg(distinct identifiers.identifiers__value, ','),8) from '[0-9]*')
		when substring(substring(string_agg(distinct identifiers.identifiers__value, ','),10) from '[0-9]*') = ''
		then substring(substring(string_agg(distinct identifiers.identifiers__value, ','),11) from '[0-9]*')
		when substring(substring(string_agg(distinct identifiers.identifiers__value, ','),8) from '[0-9]*') = ''
		then substring(substring(string_agg(distinct identifiers.identifiers__value, ','),10) from '[0-9]*')
		end as "oclc"
	--local_id  -- REQUIRED
		--status	-- NA
	--	case
	--		when string_agg(distinct items.status__name, '') = 'Withdrawn' then 'WD'
	--		when string_agg(distinct items.status__name, '') in ('Unavailable', 'Unknown', 'Order closed', 'On order') then ''
	--		when string_agg(distinct items.status__name, '') in ('Aged to lost', 'Declared lost', 'Missing', 'Long missing', 'Lost and paid', 'Claimed returned') then 'LM'
	--		else 'CH'
	--		end as "status",
	--condition -- NA
	--	case
	--		when string_agg(distinct conditions."name", ', ') is null then ''
	--		else 'BRT' 
	--		end as "condition",
	--enum_chron -- NA
	--	string_agg(distinct items.enumeration, '') || ' ' || string_agg(distinct items.chronology, '') || ' ' || string_agg(distinct items.volume, '') as "enum_chron",
	--issn --OPTIONAL
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
join
	inventory.location__t as locations on 
	locations.id = holdings.effective_location_id
where substring(locations.code, 0, 2) = 'U'
and identifiers.identifiers__identifier_type_id = '439bfbae-75bc-4f74-9fc7-b2a2d47ce3ef' --OCLC
--and (items.chronology is not null or items.enumeration is not null or items.volume is not null)
and items.material_type_id in ('b809fdbe-ec98-4f8a-bc06-2785916b480b', '9ba64788-e99e-4dd2-ac00-57195925c6df')
group by "local_id"
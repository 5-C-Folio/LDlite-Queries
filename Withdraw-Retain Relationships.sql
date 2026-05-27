-- A faster Version of the Withdraw/Retain report using TEMP tables instead of the WITH clause

-- TEMP select_items
-- Creates a temporary table only containing item data for items in the barcode list.
SELECT * 
INTO TEMP TABLE select_items 
FROM inventory.item__t as items
where
		items.barcode in ({Barcode File (no headers or punctuation)|SINGLE_COLUMN_CSV_NO_HEADER})
;

-- TEMP UM_holdings_on_instance
-- Creates a temporary table with all non-suppressed UM Holdings, and Non-UM Holdings on the Instance as well as any EAST commitment notes for Items (By Barcode)
select
	items.barcode as "Item Barcode",
	instances.id as "Instance UUID",
	coalesce(string_agg(distinct instances.hrid, ''),'') as "Instance HRID",
	coalesce(string_agg(distinct items.status__name,
	''),'') as "Item Status",
	coalesce(count(distinct instance_holdings.id) filter(
		where
			locations.name like 'UM%'
			and (instance_holdings.discovery_suppress is null
				or instance_holdings.discovery_suppress = false)),
		0) as "Non-suppressed UM Holdings on Instance",
	coalesce(string_agg(distinct locations.code,
		', ') filter(
		where
		locations.name like 'UM%'
		and (instance_holdings.discovery_suppress is null
		or instance_holdings.discovery_suppress = false)),'') as "Non-suppressed UM Holdings Locations",
	coalesce(count(distinct instance_holdings.id) filter(
		where
		instance_holdings.discovery_suppress is null
		or instance_holdings.discovery_suppress = false)) as "All non-suppressed Holdings on Instance",
	coalesce(string_agg(distinct locations.code,
		', ') filter(
		where
		instance_holdings.discovery_suppress is null
		or instance_holdings.discovery_suppress = false),'') as "All non-suppressed Holdings Locations",
	coalesce(string_agg(distinct instance_notes.notes__note,'')
		filter (
		where 
		note_types.name = 'Action note' 
		and instance_notes.notes__note like '%east%' 
		and instance_notes.notes__note like '%MU'),'')  as "Retention Note",
	coalesce(string_agg(distinct substring(trim(leading '0' from substring(instanceidentifiers.identifiers__value,8)) from '[0-9]*'), '|'),'') as "oclcNumber"
into temp table UM_holdings_on_instance
from
		select_items as items
left join inventory.holdings_record__t as holdings on
		holdings.id = items.holdings_record_id
left join inventory.instance__t as instances on
		instances.id = holdings.instance_id
left join inventory.holdings_record__t as instance_holdings on
		instance_holdings.instance_id = instances.id
left join inventory.location__t as locations on
	locations.id = instance_holdings.permanent_location_id
left join inventory.instance__t__notes as instance_notes on
	instances.id = instance_notes.id
left join inventory.instance_note_type__t as note_types on
	note_types.id = instance_notes.notes__instance_note_type_id
left join inventory.instance__t__identifiers as instanceidentifiers on
	instanceidentifiers.id = instances.id and instanceidentifiers.identifiers__identifier_type_id = '439bfbae-75bc-4f74-9fc7-b2a2d47ce3ef'
group by
		items.barcode,
		instances.id;

-- TEMP items_on_holdings
-- Creates a temporary table with the number of items without the 'Withdrawn', 'Unavailable', 'Lost and paid', 
-- 'Unknown', or 'Long missing' statuses on the same holdings record
select
		items.barcode as "Item Barcode",
		holdings.id as "Holdings UUID",
		coalesce(count(holdings_items.barcode) filter(
where
	holdings_items.status__name not in ('Withdrawn', 'Unavailable', 'Unknown', 'Lost and paid', 'Long missing')
		and (holdings_items.discovery_suppress is null
			or holdings_items.discovery_suppress = false)
		and items.barcode != holdings_items.barcode),
	0) as "Remaining Items on Holding"
into temp table items_on_holdings
from
		select_items as items
left join inventory.holdings_record__t as holdings on
		holdings.id = items.holdings_record_id
left join inventory.item__t as holdings_items on
		holdings_items.holdings_record_id = holdings.id
group by
		items.barcode,
		holdings.id;

-- TEMP items_on_instance
-- Creates a temporary table with the number of items without the 'Withdrawn', 'Unavailable', 'Lost and paid', 
-- 'Unknown', or 'Long missing' statuses on the same instance record
select
		items.barcode as "Item Barcode",
		instances.id as "Instance UUID",
		count(holdings_items.id) filter(
	where 
			holdings_items.status__name not in ('Withdrawn', 'Unavailable', 'Unknown', 'Lost and paid', 'Long missing')
		and (holdings_items.discovery_suppress is null
			or holdings_items.discovery_suppress = false)
		and items.barcode != holdings_items.barcode) as "Remaining Items on Instance"
into temp table items_on_instance
from
		select_items as items
left join inventory.holdings_record__t as holdings on
		holdings.id = items.holdings_record_id
left join inventory.instance__t as instances on
		instances.id = holdings.instance_id
left join inventory.holdings_record__t as instance_holdings on
		instance_holdings.instance_id = instances.id
left join inventory.item__t as holdings_items on 
		instance_holdings.id = holdings_items.holdings_record_id
group by
		items.barcode,
		instances.id;
	
-- Synthesizes data from the created TEMP tables for the final report.
select 
	UM_holdings_on_instance."Item Barcode",
	UM_holdings_on_instance."Instance UUID",
	UM_holdings_on_instance."Instance HRID",
	UM_holdings_on_instance."Item Status",
	"Non-suppressed UM Holdings on Instance",
	"Non-suppressed UM Holdings Locations",
	"All non-suppressed Holdings on Instance",
	"All non-suppressed Holdings Locations",
	"Remaining Items on Holding",
	"Remaining Items on Instance",
	"Retention Note",
	"oclcNumber"
from
	UM_holdings_on_instance
left join items_on_holdings on
	items_on_holdings."Item Barcode" = UM_holdings_on_instance."Item Barcode"
left join items_on_instance on
	items_on_instance."Item Barcode" = UM_holdings_on_instance."Item Barcode"
order by
	UM_holdings_on_instance."Item Barcode" desc;
	
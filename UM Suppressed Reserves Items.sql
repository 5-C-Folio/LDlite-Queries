with 
parameters as (
select
	'{Semester (YYYY Spring/Summer/Fall/Winter)}':: VARCHAR AS semester --Use this line if using the LDlite Reporting Tool
	--'2023 Spring':: VARCHAR as semester --Use this line if NOT using the LDlite Reporting Tool
   )
select
	distinct
	items.barcode as "Items Barcode",
	holdings.hrid as "Holdings HRID",
	instances.hrid as "Insances HRID",
	items.discovery_suppress as "Item Suppressed",
	holdings.discovery_suppress as "Holdings Suppressed",
	instances.discovery_suppress as "Instance Suppressed"
from
	courses.coursereserves_reserves__t as reserves
left join courses.coursereserves_courselistings__t as listing on
	listing.id = reserves.course_listing_id
left join courses.coursereserves_terms__t as term on
	term.id = listing.term_id
left join inventory.item__t as items on
	items.id = reserves.item_id 
left join inventory.holdings_record__t as holdings on
	holdings.id = items.holdings_record_id 
left join inventory.instance__t as instances on
	instances.id = holdings.instance_id 
left join inventory.location__t as locations on
	locations.id = holdings.effective_location_id
where
	term."name" = (select semester from parameters)
	and (
	items.discovery_suppress 
	or holdings.discovery_suppress
	or instances.discovery_suppress
	)
	and locations."name"  like 'U%'

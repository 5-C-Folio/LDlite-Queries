--In-Transit Items Report
with 
parameters as (
select
	'{Institution Code (AC, HC, MH, SC, UM)}':: VARCHAR AS institution --Use this line if using the LDlite Reporting Tool
	--'UM':: VARCHAR as institution --Use this line if NOT using the LDlite Reporting Tool
   )
select
	item.id as "Item ID",
	item.barcode,
	coalesce(holdings.call_number_prefix, '') || coalesce(holdings.call_number, '') || coalesce(holdings.call_number_suffix, '') as "Holdings Call Number",
	item.status__name,
	locations.name,
	item.last_check_in__date_time::date,
	current_date - item.last_check_in__date_time::date as "Days Since Last Check-in"
from
	inventory.item__t as item
join inventory.location__t as locations on
	locations.id = item.effective_location_id
left join inventory.holdings_record__t as holdings on
	holdings.id = item.holdings_record_id 
where
	item.status__name = 'In transit'
	and locations.name like (
	select
		institution
	from
		parameters) || '%'
order by "Holdings Call Number"
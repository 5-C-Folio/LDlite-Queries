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
	substring(regexp_replace(coalesce(item.effective_call_number_components__prefix,''),'\n', '') || regexp_replace(coalesce(item.effective_call_number_components__call_number,''),'\n', '') || regexp_replace(coalesce(item.effective_call_number_components__call_number, ''),'\n', ''), 0, length(regexp_replace(coalesce(item.effective_call_number_components__prefix,''),'\n', '') || regexp_replace(coalesce(item.effective_call_number_components__call_number,''),'\n', '') || regexp_replace(coalesce(item.effective_call_number_components__call_number, ''),'\n', ''))/2+1)  as "Effective Call Number",
	item.status__name,
	locations.name as "Item Effective Location",
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
order by "Item Effective Location", "Effective Call Number"
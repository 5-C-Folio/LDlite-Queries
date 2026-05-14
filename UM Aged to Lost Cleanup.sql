-- UM Aged to lost items where:
-- 		Billed to UM Patrons in the Staff, Faculty, Graduate, and Undergraduate patron groups
-- 		Bills for non-UM patrons are manually cleaned up as part of reconciliation
-- 		Bills for UM Resident Alums are not currently being cleaned up (as of 4/6/2026)
with 
parameters as (
select
	to_date('{Billed Date is Before|DATE}':: varchar, 'YYYY-MM-DD') AS billed_before_date
	--to_date('2023-07-01':: varchar, 'YYYY-MM-DD') as billed_before_date --Use this line if NOT using the LDlite Reporting Tool
   )
select
	item.id as "Item ID",
	item.barcode,
	substring(regexp_replace(coalesce(item.effective_call_number_components__prefix,''),'\n', '') || regexp_replace(coalesce(item.effective_call_number_components__call_number,''),'\n', '') || regexp_replace(coalesce(item.effective_call_number_components__call_number, ''),'\n', ''), 0, length(regexp_replace(coalesce(item.effective_call_number_components__prefix,''),'\n', '') || regexp_replace(coalesce(item.effective_call_number_components__call_number,''),'\n', '') || regexp_replace(coalesce(item.effective_call_number_components__call_number, ''),'\n', ''))/2+1)  as "Effective Call Number",
	item.status__name,
	locations.name as "Item Effective Location",
	item.status__date as "Status Last Updated",
	feefine.metadata__created_date as "Date Billed",
	patrongroup.desc as "Patron Group",
	users.external_system_id as "Patron External System ID"
from
	inventory.item__t as item
join inventory.location__t as locations on
	locations.id = item.effective_location_id::UUID
left join inventory.holdings_record__t as holdings on
	holdings.id = item.holdings_record_id 
left join inventory.service_point__t as servicepoint on
	servicepoint.id = item.last_check_in__service_point_id::UUID
left join circulation.loan__t as loans on
	loans.item_id=item.id and loans.status__name != 'Closed'
left join feesfines.accounts__t as feefine on 
	feefine.loan_id = loans.id and feefine.status__name != 'Closed'
left join users.users__t as users on
	users.id = feefine.user_id 
left join users.groups__t as patrongroup on
	patrongroup.id = users.patron_group 
where
	item.status__name = 'Aged to lost'
	and locations.name like 'UM%'
	and feefine.metadata__created_date < (select billed_before_date from parameters)
	and patrongroup.desc in ('Faculty','Staff','Graduate','Undergraduate')
	and users.external_system_id like '%@umass.edu'
order by "Date Billed"
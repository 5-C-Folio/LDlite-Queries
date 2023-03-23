select
	string_agg(distinct sas__t__periods.name::text, ', ') as "Agreement Title",
	string_agg(distinct date_part('day'::text, (sas__t__periods.periods__end_date || ' 00:00:00')::timestamp-current_date::timestamp)::text, ', ') as "Days Until Resource End Date",
	string_agg(distinct sas__t__periods.periods__end_date::text, ', ') as "Resource End Date",
	string_agg(distinct sas__t__periods.periods__note::text, ', ') as "Period Note",
	string_agg(distinct sas__t__periods.cancellation_deadline::text, ', ') as "Cancelation Deadline",
	string_agg(distinct organizations__t.name::text, ', ') as "Primary Vendor",
	string_agg(distinct po_line__t.details__receiving_note::text, ', ') as "PoLine Receiving Notes",
	sum(po_line__t.cost__po_line_estimated_price) as "Sum of PO line Estimated Costs",
	string_agg(distinct material_type__t.name::text, ', ') as "Material Type(s)"
from
	agreements.sas__t__periods
join
	agreements.sas__t__orgs on
	sas__t__periods.id = sas__t__orgs.id
left join 
	agreements.org__t on
	org__t.id = substring(sas__t__orgs.orgs__org, 14, 36)
left join
	organizations.organizations__t on 
	organizations__t.id = org__t.orgs_uuid
join 
	agreements.entitlement__t on
	entitlement__t.owner__id = sas__t__periods.id
join 
	agreements.entitlement__t__po_lines on
	entitlement__t__po_lines.id = entitlement__t.id
join 
	orders.po_line__t on
	entitlement__t__po_lines.po_lines__po_line_id = po_line__t.id
join 
	inventory.material_type__t on
	po_line__t.eresource__material_type = material_type__t.id
where
	date_part('day'::text, (sas__t__periods.periods__end_date || ' 00:00:00')::timestamp-current_date::timestamp)<= 120
	and date_part('day'::text, (sas__t__periods.periods__end_date || ' 00:00:00')::timestamp-current_date::timestamp) > 0
	--sas__t.end_date is not Null
	and sas__t__periods.name like 'UM%'
	and sas__t__periods.periods__period_status = 'current'
	and sas__t__orgs.orgs__primary_org = 'true'
group by sas__t__periods.id
order by "Days Until Resource End Date"
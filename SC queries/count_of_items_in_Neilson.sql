select 
	locations.name,
	COALESCE(count(items.id),0) "Item Count"
	--effective_call_number_components__call_number
from inventory.location__t as locations
left join
    inventory.item__t as items on
    locations.id = items.effective_location_id
where locations.library_id = 'd541a5ab-50d8-4822-83fc-8469ddfcbb57' and locations.id not in ('67204874-e4d7-495b-9247-62cd27d9ea31', '272372df-cbc8-4980-98e4-47f580b5b3b0')
--where locations.id = '272372df-cbc8-4980-98e4-47f580b5b3b0' and effective_call_number_components__type_id = '402c6f5d-e345-4937-a3a8-30efe6eb0368' --stacks/LC
	--and effective_call_number_components__call_number <= 'PT'  --stacks ground floor
	--and effective_call_number_components__call_number between 'PS' and 'QB478' --stacks first floor
	--and effective_call_number_components__call_number between 'QB479' and 'TX714' --stacks second floor
	--and effective_call_number_components__call_number >= 'TX715' --stacks third floor
--order by effective_call_number_components__call_number asc;
group by locations.name

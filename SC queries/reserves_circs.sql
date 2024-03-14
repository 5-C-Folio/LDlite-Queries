select distinct 
	it2.title as "Title",
    string_agg(distinct cct.department_object__name, ', ') as "Department names",
    string_agg(distinct terms."name", ', ') as "Course terms",
    locationsB."name" as "Holdings permanent location",
    hrt.call_number as "Call number",
    it.barcode as "Barcode",
    it.volume as "Volume",
    coalesce(count(distinct alt.loan__id), 0) as "Reserve circulations",
    string_agg(distinct locationsC."name", ', ') as "Reserve circ location"
from
    courses.coursereserves_reserves__t reserves
    left join inventory.item__t it on it.id = reserves.item_id 
    left join courses.coursereserves_courses__t cct  on reserves.course_listing_id = cct.course_listing_id
    left join courses.coursereserves_terms__t as terms on cct.course_listing_object__term_id = terms.id
    left join inventory.holdings_record__t hrt on hrt.id = it.holdings_record_id 
    left join inventory.location__t as locationsB on hrt.permanent_location_id = locationsB.id
    left join inventory.instance__t it2 on it2.id = hrt.instance_id 
    left join circulation.audit_loan__t alt on alt.loan__item_id = it.id
    	and (alt.loan__action in ('checkedout', 'checkedOutThroughOverride', 'renewed', 'renewedThroughOverride')
    	and alt.loan__item_effective_location_id_at_check_out in ('8062747a-f3e7-49bf-bb72-693c217f9c46', 'c99603f0-b291-4008-95be-a1815b6de7c6', '12daaf0e-b64b-4e3e-9b8b-7d8c26dc94b6', 'd48db17d-9b8b-4cbe-9ce9-b466f7dccc21', 'ddfda504-ee40-403d-8261-4802672f5167'))
    left join inventory.location__t as locationsC on alt.loan__item_effective_location_id_at_check_out = locationsC.id 
where cct.department_object__name like ('SC') || '%'
	--and it.barcode = '310183692343873'
group by 1,4,5,6,7
order by 2,3
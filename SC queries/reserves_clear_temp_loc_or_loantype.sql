select
    distinct 
    reserves.item_id as "Item UUID",
    it.barcode as "Barcode",
	it2.index_title as "Title",
    cct.name as "Course name",
    terms."name" as "Course term",
    locationsB."name" as "Holdings permanent location",
    hrt.call_number as "Call number",
    locationsA."name" as "Item temp location",
    ltt."name" as "Item temp loan type"
from
    courses.coursereserves_reserves__t reserves
    left join inventory.item__t it on it.id = reserves.item_id 
    left join courses.coursereserves_courses__t cct  on reserves.course_listing_id = cct.course_listing_id
    left join inventory.location__t as locationsA on it.temporary_location_id = locationsA.id
    left join courses.coursereserves_terms__t as terms on cct.course_listing_object__term_id = terms.id
    left join inventory.loan_type__t ltt  on ltt.id = it.temporary_loan_type_id
    left join inventory.holdings_record__t hrt on hrt.id = it.holdings_record_id 
    left join inventory.location__t as locationsB on hrt.permanent_location_id = locationsB.id
    left join inventory.instance__t it2 on it2.id = hrt.instance_id 
where cct.department_object__name like ('SC') || '%'
	and terms."name" in ('2022 Summer', '2022 Fall', '2023 Spring', '2023 Summer', '2023 Fall')
	and (ltt."name" is not null or locationsA."name" is not null) 
order by terms."name" asc;
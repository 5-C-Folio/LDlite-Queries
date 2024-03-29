-- Retrieves the total number of times reserves items were circulated during the specified semester.
with 
parameters as (
select
	'{Semester (YYYY Spring/Summer/Fall/Winter)}':: VARCHAR AS semester --Use this line if using the LDlite Reporting Tool
	--'2023 Spring':: VARCHAR as semester --Use this line if NOT using the LDlite Reporting Tool
   )
select
	string_agg(distinct instances.title, '') as "Title",
	items.barcode as "Barcode",
	string_agg(distinct instructor.course_listing_object__instructor_objects__name, ', ') as "Instructor Name",
	string_agg(distinct course.course_number, ', ') as "Course Code",
	coalesce(count(loan.id),0) as "Circ Count"
from inventory.item__t as items
join inventory.holdings_record__t as holdings on
	holdings.id = items.holdings_record_id 
join inventory.instance__t as instances on
	holdings.instance_id = instances.id  
left outer join circulation.loan__t as loan on
	items.id = loan.item_id
join courses.coursereserves_reserves__t as reserves on 
	reserves.item_id = items.id
join courses.coursereserves_courselistings__t as listing on
	listing.id = reserves.course_listing_id
join courses.coursereserves_courses__t as course on
	course.course_listing_id = listing.id 
join courses.coursereserves_terms__t as term on 
	term.id = listing.term_id
join courses.coursereserves_courses__t__course_listing_object__instructor_ob as instructor on
	instructor.id = course.id
where
	(loan.loan_date::date >= term.start_date::date or loan.loan_date is null)
	and (loan.loan_date::date <= term.end_date::date or loan.loan_date is null)
	and term."name" = (select semester from parameters)
	and listing.location_id = 'ecec3f71-feed-41b4-bd94-f2de28b4343b'
	AND (loan.user_id != '9fe25287-12e8-59d6-8e61-8a865c7db6da' or loan.user_id is null)
group by items.barcode
order by "Circ Count" desc
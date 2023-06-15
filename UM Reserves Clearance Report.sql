with 
parameters as (
select
	'{Semester (YYYY Spring/Summer/Fall/Winter)}':: VARCHAR AS semester --Use this line if using the LDlite Reporting Tool
	--'2023 Spring':: VARCHAR as semester --Use this line if NOT using the LDlite Reporting Tool
   )
select
	string_agg(distinct terms.name, ', ') as "Term(s)",
	string_agg(distinct temp_location."name",'') as "Temporary Location",
	string_agg(distinct temp_loan."name",'') as "Temporary Loan Type",
	string_agg(distinct instances.title,'') as "Title",
	substring(string_agg(distinct regexp_replace(coalesce(items.effective_call_number_components__prefix,''),'\n', '') || regexp_replace(coalesce(items.effective_call_number_components__call_number,''),'\n', '') || regexp_replace(coalesce(items.effective_call_number_components__call_number, ''),'\n', ''), ''), 0, length(string_agg(distinct regexp_replace(coalesce(items.effective_call_number_components__prefix,''),'\n', '') || regexp_replace(coalesce(items.effective_call_number_components__call_number,''),'\n', '') || regexp_replace(coalesce(items.effective_call_number_components__call_number, ''),'\n', ''), ''))/2+1)  as "Call Number",
	string_agg(distinct items.barcode,'') as "Item Barcode",
	string_agg(distinct courses."name", ', ') as "Course Name(s)",
	string_agg(distinct instructors.course_listing_object__instructor_objects__name, ', ') as "Instructor Name(s)",
	string_agg(distinct courses.course_number, ', ') as "Course Code(s)",
	string_agg(distinct material_type."name", '') as "Material Type"
from
	inventory.item__t as items
--Reserves
left join courses.coursereserves_reserves__t as reserves on
	reserves.item_id = items.id
left join courses.coursereserves_courselistings__t as course_listing on
	course_listing.id = reserves.course_listing_id
--Courses
left join courses.coursereserves_courses__t as courses on
	course_listing.id = courses.course_listing_id  
--Instructors
left join courses.coursereserves_courses__t__course_listing_object__instructor_ob as instructors on 
	instructors.id = courses.id
--Terms
left join courses.coursereserves_terms__t as terms on
	courses.course_listing_object__term_id = terms.id
--Holdings
join inventory.holdings_record__t as holdings on
	holdings.id = items.holdings_record_id 
--Instances
join inventory.instance__t as instances on
	instances.id = holdings.instance_id 
--Temp Location
left join inventory.location__t as temp_location on
	temp_location.id = items.temporary_location_id
--Temp Loan Type
left join inventory.loan_type__t as temp_loan on
	temp_loan.id = items.temporary_loan_type_id
left join inventory.material_type__t as material_type on
	material_type.id = items.material_type_id 
where
	temp_location.code = 'UMREP'
	and temp_loan."name" = 'Reserve 4 Hour'
	and terms.name = (select semester from parameters)
group by items.id
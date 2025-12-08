--Retrieves all items with a permanent or temporary reserves loan type and location from a specified semester.
--Last updated: June 6, 2024
with 
parameters as (
select
	'{Semester (YYYY Spring/Summer/Fall/Winter)}':: VARCHAR AS semester --Use this line if using the LDlite Reporting Tool
	--'2024 Spring':: VARCHAR as semester --Use this line if NOT using the LDlite Reporting Tool
   )
select
	string_agg(distinct terms.name, ', ') as "Term(s)",
	string_agg(distinct effective_location."name",'') as "Effective Location",
	string_agg(distinct temp_loan."name",'') as "Temporary Loan Type",
	string_agg(distinct perm_loan."name", '') as "Permanent Loan Type",
	string_agg(distinct instances.title,'') as "Title",
	regexp_replace(string_agg(distinct coalesce(items.effective_call_number_components__prefix, ''), '') || string_agg(distinct coalesce(items.effective_call_number_components__call_number, ''), '') || string_agg(distinct coalesce(items.effective_call_number_components__suffix, ''), ''), '\n', '', 'g') as "Call Number", 
	string_agg(distinct items.barcode,'') as "Item Barcode",
	string_agg(distinct items.id, '') as "Item ID",
	string_agg(distinct courses."name", ', ') as "Course Name(s)",
	string_agg(distinct instructors.course_listing_object__instructor_objects__name, ', ') as "Instructor Name(s)",
	string_agg(distinct instruct_users.personal__email, ', ') as "Instructor Email(s)",
	string_agg(distinct courses.course_number, ', ') as "Course Code(s)",
	string_agg(distinct material_type."name", '') as "Material Type"
from
	inventory.item__t as items
--Reserves
left join courses.coursereserves_reserves__t as reserves on
	text(reserves.item_id) = text(items.id)
left join courses.coursereserves_courselistings__t as course_listing on
	text(course_listing.id) = text(reserves.course_listing_id)
--Courses
left join courses.coursereserves_courses__t as courses on
	text(course_listing.id) = text(courses.course_listing_id)
--Instructors
left join courses.coursereserves_courses__t__course_listing_object__instructor_ob as instructors on 
	text(instructors.id) = text(courses.id)
--Instructor User Records
left join users.users__t as instruct_users on 
	text(instruct_users.barcode) = text(instructors.course_listing_object__instructor_objects__barcode)
--Terms
left join courses.coursereserves_terms__t as terms on
	text(courses.course_listing_object__term_id) = text(terms.id)
--Holdings
join inventory.holdings_record__t as holdings on
	text(holdings.id) = text(items.holdings_record_id)
--Instances
join inventory.instance__t as instances on
	text(instances.id) = text(holdings.instance_id) 
--Effective Location
left join inventory.location__t as effective_location on
	text(effective_location.id) = text(items.effective_location_id )
--Temp Loan Type
left join inventory.loan_type__t as temp_loan on
	text(temp_loan.id) = text(items.temporary_loan_type_id)
--Perm Loan Type
left join inventory.loan_type__t as perm_loan on
	text(perm_loan.id) = text(items.permanent_loan_type_id )
--Material Type
left join inventory.material_type__t as material_type on
	text(material_type.id) = text(items.material_type_id)
where
	effective_location.code = 'UMREP'
	and (temp_loan."name" = 'Reserve 4 Hour' or perm_loan."name" = 'Reserve 4 Hour')
	and terms.name = (select semester from parameters)
group by items.id
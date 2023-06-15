with 
parameters as (
select
	'{Institution Code (AC, HC, MH, SC, UM)}':: VARCHAR AS institution, --Use this line if using the LDlite Reporting Tool
	'{Semester (YYYY Spring/Summer/Fall/Winter)}':: VARCHAR AS semester, --Use this line if using the LDlite Reporting Tool
	LOWER('{Material Type (For any material type use %)}')::VARCHAR AS material --Use this line if using the LDlite Reporting Tool
	--'MH':: VARCHAR as institution, --Use this line if NOT using the LDlite Reporting Tool
    --'2023 Spring':: VARCHAR as semester, --Use this line if NOT using the LDlite Reporting Tool
    --LOWER('E-Book'::VARCHAR) as material --Use this line if NOT using the LDlite Reporting Tool
   )
select
	distinct 
    reserves.item_id as "Item ID"
	--reserves.copied_item__barcode as "Item Barcode",
	--reserves.copied_item__title "Title",
	--courses.course_listing_object__term_id as "Term ID",
	--courses.name as "Course Name",
	--terms."name" as "Term",
	--effectivelocation."name" as "Effective Item Location",
	--temploantype."name" as "Temp Loan Type",
	--templocation."name" as "Temp Item Location"
from
	courses.coursereserves_reserves__t reserves
left join inventory.item__t as items on
	items.id = reserves.item_id
left join courses.coursereserves_courses__t as courses on
	reserves.course_listing_id = courses.course_listing_id
left join inventory.location__t as effectivelocation on
	items.effective_location_id = effectivelocation.id
left join inventory.location__t as templocation on
	items.temporary_location_id = templocation.id
left join courses.coursereserves_terms__t as terms on
	courses.course_listing_object__term_id = terms.id
left join inventory.loan_type__t as temploantype on
	temploantype.id = items.temporary_loan_type_id
left join inventory.material_type__t as material_type on
	material_type.id = items.material_type_id 
where
	courses.department_object__name like (select institution from parameters) || '%'
	and terms."name" = (select semester	from parameters)
	and LOWER(material_type.name) like (select material from parameters)
order by reserves.item_id asc
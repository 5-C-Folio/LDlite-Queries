select
	reserves.copied_item__title as "Item Title",
	reserves.copied_item__call_number as "Call Number",
	material_type.name as "Material Type",
	items.barcode as "Item Barcode",
	courses.course_number as "Course Number",
	instructors.instructor_objects__name as "Instructor",
	courses.name
from
	courses.coursereserves_reserves__t as reserves
left join courses.coursereserves_courselistings__t as course_listings on
	course_listings.id = reserves.course_listing_id
left join courses.coursereserves_courses__t as courses on
	courses.course_listing_id = course_listings.id
left join inventory.item__t as items on
	items.id = reserves.item_id 
left join inventory.material_type__t as material_type on
	material_type.id = items.material_type_id 
left join courses.coursereserves_courselistings__t__instructor_objects as instructors on 
	instructors.id = course_listings.id
where course_listings.location_id  = 'ecec3f71-feed-41b4-bd94-f2de28b4343b'
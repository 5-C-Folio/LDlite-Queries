select 
	permSets.display_name as "Permission Set Name",
	string_agg(distinct subPerms.display_name, ', ') as "Sub Permissions"
from  perms.permissions__t__sub_permissions as permSets 
join perms.permissions__t as subPerms
	on subPerms.permission_name = permSets.sub_permissions 
where permsets.mutable=TRUE 
group by permSets.display_name 

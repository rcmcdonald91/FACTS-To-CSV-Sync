SELECT

	cs.SchoolCode as 'School_id',
	
	cs.SchoolName as 'School_name',
	
	cs.CollegeBoardSchoolCode as 'State_id',
	
	cs.Address as 'School_address',
	
	cs.City as 'School_city',
	
	cs.State as 'School_state',
	
	cs.Zip as 'School_zip',
	
	cs.Phone as 'School_phone'

	
FROM

	dbo.ConfigSchool cs
	
WHERE

	cs.Active = 1

SELECT

	cs.SchoolCode as 'School_id',
	
	cs.SchoolName as 'School_name',
	
	cs.SchoolCode as 'School_number',
	
	cs.CollegeBoardSchoolCode as 'State_id',
	
	cs.Address as 'School_address',
	
	cs.City as 'School_city',
	
	cs.State as 'School_state',
	
	cs.Zip as 'School_zip',
	
	cs.Phone as 'School_phone',
	
	CONCAT(st.FirstName, ' ', st.LastName) as 'Principal',
	
	st.Email as 'Principal_email'
	
FROM
	dbo.ConfigSchool cs

JOIN dbo.StaffSchools ss
	ON ss.SchoolCode = cs.SchoolCode
	
JOIN dbo.Staff st
	ON st.StaffID = ss.StaffID
	
WHERE
	cs.Active = 1
	AND st.Active = 1
	AND st.StaffID IN (SELECT MIN(st.StaffID) FROM dbo.Staff st WHERE st.Occupation = 'Principal' GROUP BY st.StaffID)

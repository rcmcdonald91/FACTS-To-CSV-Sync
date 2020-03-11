SELECT DISTINCT

	ss.SchoolCode as 'School_id',
	
	st.PersonID as 'Staff_id',
	
	st.Email as 'Staff_email',
	
	st.FirstName as 'First_name',
	
	st.LastName as 'Last_name',
	
	st.Department as 'Department',	
	
	st.Occupation as 'Title',
	
	'' as 'Role',
	
	'' as 'Username',
	
	'' as 'Password'
	
FROM
	dbo.Staff st
	
JOIN dbo.StaffSchools ss
	ON ss.StaffID = st.StaffID

WHERE
	st.Active = 1
	AND st.StaffID NOT IN (
		
		SELECT DISTINCT

			st.PersonID
	
		FROM
			dbo.Staff st

		JOIN dbo.Classes cl
			ON cl.StaffID = st.PersonID 
			OR cl.AltStaffID = st.PersonID 
			OR cl.AidID = st.PersonID

		WHERE
			st.Active = 1
			AND cl.YearID IN (SELECT YearID FROM dbo.SchoolYear y WHERE GETDATE() BETWEEN y.FirstDay AND y.LastDay)
			
	)

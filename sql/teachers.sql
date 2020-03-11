SELECT DISTINCT

	ss.SchoolCode as 'School_id',
	
	st.PersonID as 'Teacher_id',
	
	st.PersonID as 'Teacher_Number',

	'' as 'State_teacher_id',
	
	st.LastName as 'Last_name',
	
	st.MiddleName as 'Middle_name',
	
	st.FirstName as 'First_name',
	
	st.Email as 'Teacher_email',
	
	st.Occupation as 'Title',
	
	'' as 'Username',
	
	'' as 'Password'
	
FROM
	dbo.Staff st
	
JOIN dbo.StaffSchools ss
	ON ss.StaffID = st.StaffID
	
JOIN dbo.Classes cl
	ON cl.StaffID = st.PersonID 
	OR cl.AltStaffID = st.PersonID 
	OR cl.AidID = st.PersonID

WHERE
	st.Active = 1
	AND cl.YearID IN (SELECT YearID FROM dbo.SchoolYear y WHERE GETDATE() BETWEEN y.FirstDay AND y.LastDay)

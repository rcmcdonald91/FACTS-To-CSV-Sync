DECLARE @schoolCode VARCHAR(255) = (SELECT cs.Schoolcode FROM dbo.ConfigSchool cs)

DECLARE @currentSchoolYearID INT = (SELECT MAX(YearID) FROM dbo.SchoolYear y)

SELECT DISTINCT

	@schoolCode as 'School_id',
	
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
			AND cl.YearID = @currentSchoolYearID
			
	)

DECLARE @sc VARCHAR(255) = (SELECT cs.Schoolcode FROM dbo.ConfigSchool cs)

DECLARE @syid INT = (SELECT MAX(YearID) FROM dbo.SchoolYear y)

SELECT DISTINCT

	@sc as 'School_id',
	
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

JOIN dbo.Classes cl ON cl.StaffID = st.PersonID OR cl.AltStaffID = st.PersonID

WHERE

	st.Active = 1
	
	AND cl.YearID = @syid

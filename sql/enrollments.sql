SELECT
	
	st.SchoolCode as 'School_id',
	
	cl.ClassID as  'Section_id',
	
	st.StudentID as 'Student_id'

FROM

	dbo.Students st
	
JOIN dbo.Roster r 
	ON r.StudentID = st.StudentID

JOIN dbo.Classes cl 
	ON cl.ClassID = r.ClassID
	
JOIN dbo.ConfigSchool cs
	ON cs.SchoolCode = st.SchoolCode
	
JOIN dbo.SchoolYear y
	ON y.YearID = cs.DefaultYearID
	
WHERE

	st.Status = 'Enrolled'
	
	AND cl.YearID = cs.DefaultYearID

DECLARE @syid INT = (SELECT MAX(YearID) FROM dbo.SchoolYear y)

SELECT
	
	st.SchoolCode as 'School_id',
	
	cl.ClassID as  'Section_id',
	
	st.StudentID as 'Student_id'

FROM

	dbo.Students st
	
JOIN dbo.Roster r ON r.StudentID = st.StudentID

JOIN dbo.Classes cl ON cl.ClassID = r.ClassID
	
WHERE
	
	st.Status = 'Enrolled'
	
	AND cl.YearID = @syid

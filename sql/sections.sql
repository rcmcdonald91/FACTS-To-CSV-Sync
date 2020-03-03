DECLARE @currentSchoolYearID INT = (SELECT MAX(YearID) FROM dbo.SchoolYear y)

SELECT

	co.SchoolCode as 'School_id',
	
	cl.ClassID as 'Section_id',
	
	cl.StaffID as 'Teacher_id',
	
	cl.AltStaffID as 'Teacher_2_id',
	
	cl.AidID as 'Teacher_3_id',
	
	CONCAT(cl.Name,'-',cl.Section) as 'Name',
	
	'' as 'Grade',
	
	co.Title as 'Course_name',
	
	'' as 'Period',
	
	co.Department as 'Subject',
	
	sy.SchoolYear as 'Term_name',
	
	CONVERT(varchar, sy.FirstDay, 101) as 'Term_start',
	
	CONVERt(varchar, sy.LastDay, 101) as 'Term_end'
	
FROM
	dbo.Classes cl
	
JOIN dbo.Courses co 
	ON co.CourseID = cl.CourseID

JOIN dbo.SchoolYear sy 
	ON sy.YearID = cl.YearID
 
WHERE
	cl.YearID = @currentSchoolYearID
	AND cl.ClassID IN (
	
			SELECT
				cl.ClassID
				
			FROM
				dbo.Classes cl
	
			JOIN dbo.Roster r
				ON r.ClassID = cl.ClassID
		
			JOIN dbo.Students st
				ON st.StudentID = r.StudentID
	
			WHERE
				cl.YearID = @currentSchoolYearID
				AND st.Status = 'Enrolled'
		
			GROUP BY cl.ClassID
		
	)

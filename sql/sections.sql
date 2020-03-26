SELECT

	co.SchoolCode as 'School_id',
	
	cl.ClassID as 'Section_id',
	
	NULLIF(cl.StaffID, 0) AS 'Teacher_id',
	
	NULLIF(cl.AltStaffID, 0) AS 'Teacher_2_id',
	
	NULLIF(cl.AidID, 0) as 'Teacher_3_id',
	
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
	cl.YearID IN (SELECT YearID FROM dbo.SchoolYear y WHERE GETDATE() BETWEEN y.FirstDay AND y.LastDay)
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
				st.Status = 'Enrolled'
				AND cl.YearID IN (SELECT YearID FROM dbo.SchoolYear y WHERE GETDATE() BETWEEN y.FirstDay AND y.LastDay)
		
			GROUP BY cl.ClassID
		
	)
	
	AND cl.ClassID IN (
	
			SELECT 
				cl.ClassID
				
			FROM
				dbo.Classes cl
	
			JOIN dbo.Staff st
				ON st.StaffID = cl.StaffID
				OR st.StaffID = cl.AltStaffID
				OR st.StaffID = cl.AidID
	
			WHERE
				st.Active = 1
				AND cl.YearID IN (SELECT YearID FROM dbo.SchoolYear y WHERE GETDATE() BETWEEN y.FirstDay AND y.LastDay)
	
			GROUP BY cl.ClassID
	
	)

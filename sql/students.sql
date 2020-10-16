SELECT

	st.SchoolCode as 'School_id',
	
	st.PersonID as 'Student_id',
	
	st.PersonID as 'Student_number',
	
	st.SchoolID as 'State_id',
	
	st.LastName as 'Last_name',
	
	st.MiddleName as 'Middle_name',
	
	st.FirstName as 'First_name',
	
	REPLACE(LTRIM(REPLACE(st.GradeLevel, '0', ' ')), ' ', '0') as 'Grade',
	
	st.Gender as 'Gender',
	
	st.ClassOf as 'Graduation_year',
	
	CONVERT(varchar, st.Birthdate, 101) as 'DOB',
	
	st.Email as 'Student_email',
	
	ps.Relationship as 'Contact_relationship',
	
	'Guardian' as 'Contact_type',
	
	CONCAT(p.FirstName,' ',p.LastName) as 'Contact_name',
	
	p.Email as 'Contact_email',
	
	ps.ParentID as 'Contact_sis_id',
	
	'' as 'Username',
	
	'' as 'Password'
	
FROM
	dbo.Students st

LEFT JOIN dbo.Parent_Student ps 
	ON ps.StudentID = st.StudentID
	AND ps.Custody = 1
	AND ps.ParentID IN (SELECT MIN(p.PersonID) FROM dbo.Person p JOIN dbo.Parent_Student ps ON ps.ParentID = p.PersonID GROUP BY ps.StudentID, p.Email)
	AND ps.ParentID NOT IN (SELECT st.StudentID FROM dbo.Students st WHERE st.Status = 'Enrolled')

LEFT JOIN  dbo.Person p
	ON p.PersonID = ps.ParentID
	AND p.Deceased = 0
	
WHERE
	st.Status = 'Enrolled'

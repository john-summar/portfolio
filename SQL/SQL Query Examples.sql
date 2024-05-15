-- Relevant information about an applicant for interview purposes

SELECT Confirmation#, CONCAT(FirstName, ' ', LastName) AS ApplicantName, PermanentEmail, Semester,FirstChoicePosition, SecondChoicePosition, Major, ExpectedGraduationDate, DesiredWeeklyHours, MorningAvailability, NightAvailability, SummerAvailability,
       MondayClassSchedule, TuesdayClassSchedule, WednesdayClassSchedule, ThursdayClassSchedule, FridayClassSchedule,  Essay1, Essay2, InterviewDate
FROM Applicant
JOIN Interview
    ON Interview.ApplicantID = Applicant.ApplicantID;


--Pay information for each employee, including standard rate for the job role, starting pay rate,
--current pay rate, date of last pay raise, and number of raises the employee has had while in that job role.

SELECT Employee.HireApplicantID,(Applicant.FirstName+' '+Applicant.LastName) AS EmployeeName,
       CurrentPay,StandardRate,MAX(Evaluation.Date) As LastEval, Count(Distinct EvaluationID) AS NumOfRaises,currentpay-sum(payraise) as StartingPay
FROM Employee
JOIN Evaluation
    ON Employee.HireApplicantID = Evaluation.HireApplicantID
Left JOIN AssignedJobRole
    ON Employee.HireapplicantID = AssignedJobRole.HireApplicantID
Left JOIN JobRole
    ON JobRole.JobRoleID = AssignedJobRole.JobRoleID
JOIN Applicant
    ON Applicant.ApplicantID = Employee.HireapplicantID
Group BY Employee.HireApplicantID,CurrentPay,(Applicant.FirstName+' '+Applicant.LastName),StandardRate;

SELECT Applicant.ApplicantID,
    (Applicant.FirstName + ' ' + Applicant.LastName) as ApplicantName,
    StandardRate AS 'Standard Job Rate',
    StartPayTable.StartingPay as 'StartingPay',
    Employee.CurrentPay AS 'Current Pay',
    Evaluation.Date AS 'Date of Last Raise',
    COUNT(Evaluation.Date) as 'Number of Raises'
FROM Employee
JOIN AssignedJobRole ON AssignedJobRole.HireApplicantID = Employee.HireApplicantID
JOIN JobRole ON JobRole.JobRoleID = AssignedJobRole.JobRoleID
JOIN Applicant ON Applicant.ApplicantID = Employee.HireApplicantID
JOIN Evaluation ON Evaluation.HireApplicantID = AssignedJobRole.HireApplicantID
JOIN (SELECT Employee.HireApplicantID, (CurrentPay - PayRaise) as 'StartingPay'
    FROM Employee
    JOIN Evaluation ON Evaluation.HireApplicantID = Employee.HireApplicantID
    ) AS StartPayTable
        ON StartPayTable.HireApplicantID = Employee.HireApplicantID
GROUP BY Applicant.FirstName,Applicant.LastName, Applicant.ApplicantID, StandardRate, Employee.CurrentPay, Evaluation.Date,StartPayTable.StartingPay;


--A list of employees who do not have First Aid or CPR certificates or whose First Aid and CPR certifications expired before their last pay raise evaluation

SELECT (PointOfContactFirstName + ' ' + PointOfContactLastName) as "Employee List"
FROM Certification
JOIN CertHeld
    ON Certification.CertificationID = CertHeld.CertificationID
JOIN Evaluation
    ON Evaluation.HireApplicantID = CertHeld.ApplicantID
JOIN Assignment
    ON Assignment.HireApplicantID = Evaluation.HireApplicantID
WHERE CertName NOT IN ('First Aid', 'CPR')
    OR ExpirationDate < Evaluation.Date;

SELECT DISTINCT (FirstName +' '+ LastName) AS EmployeeName,Employee.HireApplicantID
FROM Applicant
JOIN Employee
    ON Employee.HireApplicantID = Applicant.ApplicantID
JOIN CertHeld
    ON Applicant.ApplicantID = CertHeld.ApplicantID
WHERE CertificationID NOT IN (SELECT CertificationID FROM Certification WHERE CertName IN ('CPR','First Aid'))
    OR ExpirationDate < (SELECT max(xyz)
                            FROM (SELECT max(DATE) as xyz
                                    FROM Evaluation
                                        GROUP BY HireapplicantId) as xyztbl);

--A list of employees by program, job role, and the average hours worked per week in that job role and program.

SELECT Employee.HireApplicantID, CONCAT(FirstName,' ', LastName) AS 'Full Name',Name, Jobrole.JobRoleID, HourlyExpectation
FROM Employee
JOIN Applicant
    ON Employee.HireApplicantID = Applicant.ApplicantID
JOIN AssignedJobRole    
    ON AssignedJobRole.HireApplicantID = Employee.HireApplicantID
JOIN JobRole 
    ON JobRole.JobRoleID = AssignedJobRole.JobRoleID
JOIN Program
    ON Program.ProgramID = JobRole.ProgramID
GROUP BY JobRole.JobRoleID, HourlyExpectation, Employee.HireApplicantID, Name, FirstName, LastName;


--The number of activities each program manages, and the total additional revenue brought in by each program 
SELECT Program.ProgramID, COUNT(Activity.ActivityID) as NumOfPrograms, (AdditionalCost * COUNT(StudentID)) as AdditionalRevenue
FROM Activity
JOIN Assignment
    ON Activity.ActivityID = Assignment.ActivityID
JOIN Program
    ON Program.ProgramID = Activity.ProgramID
JOIN Enrollment
    ON Enrollment.ActivityID = Activity.ActivityID
GROUP BY Program.ProgramID, AdditionalCost;


--Who all has been interviewed, and for which job they interviewed.
SELECT Applicant.FirstName, Applicant.LastName, StandardJobDescription ,Interview.InterviewDate
FROM Applicant
JOIN Interview ON Applicant.ApplicantID = Interview.ApplicantID
JOIN AssignedJobRole ON Applicant.ApplicantID = AssignedJobRole.HireApplicantID
JOIN JobRole ON AssignedJobRole.JobRoleID = AssignedJobRole.JobRoleID;


--What applicants have previously worked for the university, and what was their most recent position? 
SELECT Applicant.ApplicantID, FirstName, LastName, Position, CompanyName
FROM Applicant
JOIN JobHistory
ON Applicant.ApplicantID=JobHistory.ApplicantID
WHERE UniversityEmp= 'Yes';

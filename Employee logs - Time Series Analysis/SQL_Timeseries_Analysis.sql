
/* Query 1 
   Total working hours */
SELECT 
    Date, 
    [Employee ID], 
    (CAST([Total Hours] as decimal(10,2))) AS Total_Work_Hours
FROM [employee hours]
WHERE [In (Login time)] != 'Public Holiday/Weekend'
ORDER BY Date;

  
/* Query 2 
Average login hour for weekdays */
SELECT 
    CONVERT(VARCHAR, CONVERT(DATE, Date, 103), 105) AS Date,  -- Convert to proper DATE and back to 'DD-MM-YYYY'
    DATENAME(WEEKDAY, CONVERT(DATE, Date, 103)) AS Weekday,  -- Extract weekday name
    [Employee Level], 
    AVG(CAST(SUBSTRING([In (Login time)], 1, 2) AS INTEGER)) AS Avg_Login_Hour
FROM [employee hours]
WHERE 
     ISNUMERIC(SUBSTRING([In (Login time)], 1, 2)) = 1  
GROUP BY 
    CONVERT(DATE, Date, 103), 
    DATENAME(WEEKDAY, CONVERT(DATE, Date, 103)), 
    [Employee Level]
ORDER BY 
    CONVERT(DATE, Date, 103);



/*Query3 
Late Logins Daily */
SELECT 
    [Employee ID], Date,
    [In (Login time)] AS Late_Logins
FROM [Employee hours]
WHERE 
    ISNUMERIC(SUBSTRING("In (Login time)", 1, 2)) = 1  
    AND CAST(SUBSTRING("In (Login time)", 1, 2) AS INTEGER) > 10  
ORDER BY Late_Logins DESC; 


/*Query 4 
Early logouts */
SELECT 
    [Employee ID], 
	Date,
    COUNT(*) AS Early_Logout_Count
FROM [Employee hours]
WHERE 
    ISNUMERIC(SUBSTRING("Out (Logout time)", 1, 2)) = 1  -- Ensure valid numeric logout times
	AND CAST(SUBSTRING ([In (Login time)], 1, 2) AS INTEGER) > 9 -- Excluding who login very early
    AND CAST(SUBSTRING("Out (Logout time)", 1, 2) AS INTEGER) < 18  -- Logout before 6:00 PM
GROUP BY [Employee ID], Date 
ORDER BY [Employee ID] DESC;




/* Query 5
Overtime working hours */

SELECT 
    "Employee ID",
	Date,
    COUNT(*) AS Overtime_Days, 
    (CAST([Total Hours] AS DECIMAL(5,2)) - 9) AS Total_Overtime
FROM [employee hours]
WHERE CAST([Total Hours] AS DECIMAL(5,2)) != 0.00
    AND CAST("Total Hours" AS DECIMAL(5,2)) > 9  -- Employees who worked overtime
GROUP BY "Employee ID", Date, [Total Hours]
ORDER BY Total_Overtime DESC;



/* Query6 
  Attendance summary */
SELECT 
    [Employee ID],
    Date,

    -- Attendance Calculation
    CASE 
        WHEN [In (Login time)] = 'Public Holiday/Weekend' THEN 1
        WHEN [In (Login time)] = 'Sick Leave' THEN 0
        WHEN TRY_CAST([Total Hours] AS FLOAT) != 0.00 THEN 1 
        ELSE 0 
    END AS Attendance

FROM [Employee hours];









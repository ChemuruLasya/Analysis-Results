

/* Overall Attrition Rate */
SELECT  
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) AS Total_Churned, 
    CAST(SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) AS DECIMAL(10, 4)) 
    / COUNT(*) AS Attrition_Rate
FROM [Customers Data];
/* Used in Text boxes */




/* Attrition by Age_group */
WITH Age_Group_CTE AS (
    SELECT 
        CASE 
            WHEN Age BETWEEN 18 AND 30 THEN '18-30'
            WHEN Age BETWEEN 31 AND 45 THEN '31-45'
            WHEN Age BETWEEN 46 AND 60 THEN '46-60'
            ELSE '60+' 
        END AS Age_Group,
        Attrition_Flag
    FROM [Customers Data]
)
SELECT 
    Age_Group,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) AS Churned_Customers,
    FORMAT(SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 'N2') AS Attrition_Rate
FROM Age_Group_CTE
GROUP BY Age_Group;




/* Monthly Inactivity versus Attrition */
SELECT 
    Attrition_Flag,
    Cast(Inactive_Mon AS decimal) AS Months_Inactive
FROM [Customers Data] join [Card Details] on [Customers Data].Client_Id = [Card Details].Client_Id





/* Total contacts and Attrition */
SELECT 
    Attrition_Flag,
    CAST(Total_contacts as decimal) AS Total_Contacts
FROM [Customers Data] join [Card Details] on [Customers Data].Client_Id = [Card Details].Client_Id;





/* Segment Analysis by Income Category */
SELECT 
    Income_Category,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) AS Churned_Customers,
    FORMAT(SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 'N2') AS Attrition_Rate
FROM [Customers Data]
GROUP BY Income_Category
ORDER BY Attrition_Rate DESC;




/* Product Holding Impact */
SELECT 
    Products_held AS Total_Products_Held,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) AS Churned_Customers,
    FORMAT(SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 'N2') AS Attrition_Rate
FROM [Customers Data] join [Card Details] on [Customers Data].Client_Id = [Card Details].Client_Id
GROUP BY Products_held
ORDER BY Products_held;





/* Transaction count and Attrition */
SELECT 
    Attrition_Flag,
    CAST(Total_Trans_Cnt AS decimal) AS Transaction_Count
FROM [Customers Data] join [Card Details] on [Customers Data].Client_Id = [Card Details].Client_Id;




/* Average Transaction Amount and Attrition */
SELECT 
    Attrition_Flag,
    FORMAT(AVG(CAST(Total_Trans_Amt AS decimal)), 'N2') AS Avg_Transaction_Amount
FROM [Customers Data] join [Card Details] on [Customers Data].Client_Id = [Card Details].Client_Id
GROUP BY Attrition_Flag;





/* Likely churned customers */

With Likely_Churned_Customers AS (
    SELECT
        [Customers Data].Client_Id,
        Age,
		Gender,
		Income_Category,
		Products_held,
		Inactive_Mon,
		Total_Contacts,
		Total_Trans_Cnt,
		Total_Revolving_Bal
        
    FROM [Customers Data] join [Card Details] on [Customers Data].Client_Id = [Card Details].Client_Id
    WHERE Attrition_Flag = 'Existing Customer' -- Current customers
      AND CAST(Products_held AS INT) < 4
	  AND CAST(Inactive_Mon AS DECIMAL) > 2
      AND CAST(Total_Trans_Cnt AS INT) < 100
	  AND CAST(Total_Contacts as INT) > 0 )

select count(*) as Likely_Attrited_Customers, (select count(*) from [Customers Data] where Attrition_Flag = 'Existing Customer'
                                               ) - count(*) as Existing_Cutomers From Likely_Churned_Customers;


/* Immediate action required regarding customers from the above likely churned customers  
having income  'Less than $40K' and  '$40K-$60K' because they fall in high attrition count groups */


With Likely_Churned_Customers AS (
    SELECT Top 100
        [Customers Data].Client_Id,
        Age,
		Gender,
		Income_Category,
		Products_held,
		Inactive_Mon,
		Total_Contacts,
		Total_Trans_Cnt,
		Total_Revolving_Bal
        
    FROM [Customers Data] join [Card Details] on [Customers Data].Client_Id = [Card Details].Client_Id
    WHERE Attrition_Flag = 'Existing Customer' -- Current customers
      AND CAST(Products_held AS INT) < 4
	  AND CAST(Inactive_Mon AS DECIMAL) > 2
      AND CAST(Total_Trans_Cnt AS INT) < 100
	  AND CAST(Total_Contacts as INT) > 0 
	  AND Income_Category IN ('Less than $40K', '$40K-$60K'))
      
SELECT * FROM Likely_Churned_Customers 
Order by CAST(Total_Revolving_Bal as Decimal);








/* Below are my Queries used to find effect of some categories on Attrition but removed after plotting trends in Power BI as there is no much effect */


/* Impact of credit utilization on Attrition */
/*SELECT 
    Attrition_Flag,
    Avg_utilization_ratio AS Avg_Utilization_Ratio
FROM [Customers Data] join [Card Details] on [Customers Data].Client_Id = [Card Details].Client_Id;  */
/* After plotting overall trend instead of average, I found no major effect played by utilization ratio */

/* Transaction Behavior and Attrition */
/*SELECT 
    Attrition_Flag,
    CAST(Total_Trans_Amt AS decimal) AS Transaction_Amount,
    CAST(Total_Trans_Cnt AS decimal) AS Transaction_Count,
    CAST(Total_Cnt_Chng_Q4_Q1 AS decimal) AS Change_Transaction_Count
FROM [Customers Data] join [Card Details] on [Customers Data].Client_Id = [Card Details].Client_Id; */

/* Indicators of Attrition */
/*SELECT 
    Attrition_Flag,
    FORMAT(AVG(CAST(Months_on_book as Decimal)), 'N2') AS Avg_Relationship_months,
	FORMAT(AVG(CAST(Credit_Limit as Decimal)), 'N2') AS Avg_Credit_Limit,
    FORMAT(AVG(CAST(Total_Revolving_Bal as Decimal)), 'N2') AS Avg_Revolving_Balance

FROM [Customers Data] join [Card Details] on [Customers Data].Client_Id = [Card Details].Client_Id
GROUP BY Attrition_Flag; */

/* Indicators of Attrition */
/*SELECT 
    Attrition_Flag,
    CAST(Months_on_book as Decimal) AS Avg_Relationship_months,
    CAST(Credit_Limit as Decimal) AS Avg_Credit_Limit,
    CAST(Total_Revolving_Bal as Decimal) AS Avg_Revolving_Balance
FROM [Customers Data] join [Card Details] on [Customers Data].Client_Id = [Card Details].Client_Id */



DECLARE @StartDate date, @EndDate date
SET @StartDate = '2013-08-01'
SET @EndDate = DATEADD(day,-1,DATEADD(month,1,@StartDate))

SELECT

(select SUM(receiptamount) from receipts where PaymentType = 'ADVANCE'
and convert(date,dateentered) >= @StartDate
and CONVERT(date,dateentered) <= @EndDate) AS 'Money Out',

(select SUM(Amount) from checks where CreditorID = 9527
and convert(date,DateCreated) >= @StartDate
and CONVERT(date,DateCreated) <= @EndDate) AS 'Money In'
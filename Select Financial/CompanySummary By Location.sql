IF OBJECT_ID('Custom_CompanySummaryByLocation') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_CompanySummaryByLocation
END
GO

CREATE PROCEDURE Custom_CompanySummaryByLocation(
@StartDate date,
@EndDate date,
@LocationID int
)
AS    
BEGIN

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @Invoices money, @CreditorReceipts money, @Checks int, @CheckRuns int, @ClientsAdded int, @ClientsDeleted int, @ActiveClientsAsOf int, @ActiveClients int, @ActiveBalance money     

DECLARE @StartOfNextDayEndDate date  
SET @StartOfNextDayEndDate = CONVERT(date,dbo.StartOfNextDay(@EndDate))

SELECT @Invoices = SUM(i.Amount)  
FROM  Invoices  AS i
INNER JOIN Clients AS c
	ON c.ClientID = i.ClientID 
WHERE CONVERT(date,i.InvoiceDate) >= @StartDate   
AND CONVERT(date,i.InvoiceDate) < @StartOfNextDayEndDate    
AND c.LocationID = @LocationID

SELECT @CreditorReceipts = SUM(crs.RcvdAmount)  
FROM CreditorReceipts AS crs
RIGHT JOIN ClientCred AS cc
	ON cc.CreditorID = crs.CreditorID
INNER JOIN Clients AS c
	ON c.ClientID = cc.ClientID
WHERE CONVERT(date,crs.PaymentDate) >= @StartDate   
AND CONVERT(date,crs.PaymentDate) < @StartOfNextDayEndDate   
AND crs.BillID is not null
AND c.LocationID = @LocationID    

SELECT @Checks = COUNT(cks.CheckID)  
FROM Checks  AS cks
INNER JOIN Payments AS p
	ON p.CheckID = cks.CheckID
INNER JOIN Clients AS c
	ON c.ClientID = p.ClientID
WHERE CONVERT(date,cks.DateCreated) >= @StartDate   
AND CONVERT(date,cks.DateCreated) < @StartOfNextDayEndDate    
AND c.LocationID = @LocationID

SELECT @CheckRuns = COUNT(DISTINCT ckr.CheckRunID)  
FROM CheckRun  AS ckr
INNER JOIN Payments AS p
	ON p.CheckID >= ckr.StartCheck AND p.CheckID <= ckr.EndCheck
INNER JOIN Clients AS c
	ON c.ClientID = p.ClientID
WHERE CONVERT(date,ckr.CheckRunDate) >= @StartDate   
AND CONVERT(date,ckr.CheckRunDate) < @StartOfNextDayEndDate    
AND c.LocationID = @LocationID

SELECT @ClientsAdded = COUNT(ClientID)  
FROM Clients  
WHERE CONVERT(date,DateStart) >= @StartDate   
AND CONVERT(date,DateStart) < @StartOfNextDayEndDate   
AND Active <> 0   
AND LocationID = @LocationID 

SELECT @ClientsDeleted = COUNT(ClientID)  
FROM Clients  
WHERE  CONVERT(date,DateClose) >= @StartDate   
AND CONVERT(date,DateClose) < @StartOfNextDayEndDate   
AND Active = 0
AND LocationID = @LocationID    

SELECT @ActiveClientsAsOf = COUNT(ClientID)  
FROM Clients  
WHERE 
LocationID = @LocationID
AND (
	CONVERT(date,DateStart) < @StartOfNextDayEndDate AND Active <> 0)   
	OR (CONVERT(date,DateStart) < @StartOfNextDayEndDate AND (CONVERT(date,DateClose) >= @StartOfNextDayEndDate)
)    

SELECT @ActiveClients = COUNT(ClientID)  
FROM Clients  
WHERE Active <> 0    
AND LocationID = @LocationID

SELECT @ActiveBalance = SUM(CC.Balance)  
FROM ClientCred CC   
INNER JOIN Clients C 
	ON CC.ClientID = C.ClientID   
INNER JOIN Creditors CRED 
	ON CC.CreditorID = CRED.CreditorID   
LEFT JOIN CreditorTypes CT 
	ON CRED.CreditorType = CT.CreditorType  
WHERE CT.ISFEE = 0    
AND CT.Internal = 0   
AND C.Active <> 0    
AND C.LocationID = @LocationID 

SELECT @Invoices AS Invoices,
@CreditorReceipts AS CreditorReceipts,
@Checks AS Checks,
@CheckRuns AS CheckRuns,
@ClientsAdded AS ClientsAdded,
@ClientsDeleted AS ClientsDeleted,
@ActiveClientsAsOf AS ActiveClientsAsOf,
@ActiveClients AS ActiveClients,
@ActiveBalance AS ActiveBalance  

END
GO
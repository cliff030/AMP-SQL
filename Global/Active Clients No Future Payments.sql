IF OBJECT_ID('Custom_ActiveClientsNoFuturePayments', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_ActiveClientsNoFuturePayments
END
GO

CREATE PROCEDURE Custom_ActiveClientsNoFuturePayments
AS
BEGIN
	SELECT ClientID, LastName, FirstName
	FROM Clients
	WHERE Active = 1

	EXCEPT

	SELECT DISTINCT ClientID, LastName, FirstName
	FROM Clients AS c
	INNER JOIN ProgramScheduleDebtor AS psd
		ON psd.DebtorID = c.ClientID
	WHERE CONVERT(date,psd.DueDate) >= CONVERT(date,GETDATE())
	AND c.Active = 1

	ORDER BY ClientID
END
GO
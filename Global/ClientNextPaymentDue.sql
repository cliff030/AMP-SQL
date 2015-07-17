IF OBJECT_ID('dbo.Custom_ClientNextPaymentDue') IS NOT NULL
BEGIN
	DROP FUNCTION dbo.Custom_ClientNextPaymentDue
END
GO

CREATE FUNCTION dbo.Custom_ClientNextPaymentDue (   
	@ClientID int  
) RETURNS datetime 
BEGIN   
DECLARE @DueDate datetime   

SET @DueDate=(
				SELECT TOP 1 psd.DueDate
				FROM ProgramScheduleDebtor AS psd
				INNER JOIN ProgramPayments AS ps
					ON ps.ProgramScheduleDebtorID = psd.ProgramScheduleDebtorID
				INNER JOIN ClientCred AS cc
					ON ps.ClientCredID = cc.ClientCredID
				WHERE ps.ClientID = @ClientID
				AND dbo.StartOfDay(psd.DueDate) > dbo.StartOfDay(GETDATE())
				AND cc.CreditorID = 0
				ORDER BY psd.DueDate ASC
)   
RETURN @DueDate

END
GO
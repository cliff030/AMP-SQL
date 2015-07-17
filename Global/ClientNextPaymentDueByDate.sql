IF OBJECT_ID('Custom_ClientNextPaymentDueByDate','FN') IS NOT NULL
BEGIN
	DROP FUNCTION dbo.Custom_ClientNextPaymentDueByDate
END
GO

CREATE FUNCTION dbo.Custom_ClientNextPaymentDueByDate (   
	@ClientID int,
	@StartDate date,
	@EndDate date  
) RETURNS datetime 
BEGIN   
DECLARE @DueDate datetime   

SET @DueDate=(
				SELECT TOP 1 psd.DueDate
				FROM ProgramScheduleDebtor AS psd
				INNER JOIN ProgramPayments AS ps
					ON ps.ProgramScheduleDebtorID = psd.ProgramScheduleDebtorID
				WHERE ps.ClientID = @ClientID
				AND CONVERT(date,psd.DueDate) > @StartDate
				AND CONVERT(date,psd.DueDate) <= @EndDate
				ORDER BY psd.DueDate ASC
)   
RETURN @DueDate

END
GO
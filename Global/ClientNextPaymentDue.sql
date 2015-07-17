ALTER FUNCTION dbo.Custom_ClientNextPaymentDue (   
	@ClientID int  
) RETURNS datetime 
BEGIN   
DECLARE @DueDate datetime   

SET @DueDate=(
				SELECT TOP 1 psd.DueDate
				FROM ProgramScheduleDebtor AS psd
				INNER JOIN ProgramPayments AS ps
					ON ps.ProgramScheduleDebtorID = psd.ProgramScheduleDebtorID
				WHERE ps.ClientID = @ClientID
				AND dbo.StartOfDay(psd.DueDate) > dbo.StartOfDay(GETDATE())
				ORDER BY psd.DueDate ASC
)   
RETURN @DueDate

END
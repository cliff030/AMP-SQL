USE CSDATA8_INC

IF OBJECT_ID('Custom_GetFundAccumulation','FN') IS NOT NULL
BEGIN
	DROP FUNCTION Custom_GetFundAccumulation
END
GO

CREATE FUNCTION Custom_GetFundAccumulation(
	@ClientID int,
	@SettlementPercent float,
	@NumberOfMonths int,
	@TableName nvarchar(max)
) RETURNS money
BEGIN
DECLARE @Result money

SET @Result = ( select isnull(round(round(sum(isnull(origdebt,0))*@SettlementPercent,2)/@NumberOfMonths,0) + -29.95,0) FROM dbo.DebtorProgramDebt(@ClientID,@TableName) )

RETURN @Result

END
GO
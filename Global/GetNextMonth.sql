ALTER FUNCTION dbo.Custom_GetNextMonth(
	@CurMonth datetime
) RETURNS datetime
AS
BEGIN
	RETURN CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,@CurMonth))-1),DATEADD(mm,1,@CurMonth)),101)
END
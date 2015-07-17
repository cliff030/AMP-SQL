IF OBJECT_ID('Custom_NumberFromPhoneNumber','FN') IS NOT NULL
BEGIN
	DROP FUNCTION Custom_NumberFromPhoneNumber
END
GO

CREATE FUNCTION Custom_NumberFromPhoneNumber(
	@str nvarchar(max)
) RETURNS nvarchar(max)
AS
BEGIN
	SET @str = REPLACE(REPLACE(REPLACE(REPLACE(@str,' ',''),'(',''),')',''),'-','')
	
	RETURN @str
END
GO
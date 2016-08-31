IF OBJECT_ID('Custom_GetAMPAddress', 'TF') IS NOT NULL
BEGIN
	DROP FUNCTION Custom_GetAMPAddress
END
GO

CREATE FUNCTION dbo.Custom_GetAMPAddress()
RETURNS @Address TABLE (
	Name nvarchar(512),
	Address1 nvarchar(200),
	Address2 nvarchar(10) null,
	City nvarchar(100),
	[State] nvarchar(100),
	Zip nvarchar(20)
)
AS
BEGIN
	INSERT INTO @Address ( Name, Address1, Address2, City, [State], Zip )
	(
		SELECT Name, Address1, Address2, City, [State], Zip 
		FROM [AMP-DC].[CreditsoftCompanies].[dbo].[AMP] AS a
		WHERE a.Active = 1
	)

	RETURN
END
GO
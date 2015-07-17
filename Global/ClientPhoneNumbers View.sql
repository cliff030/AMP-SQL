IF OBJECT_ID('Custom_ClientPhoneNumbers') IS NOT NULL
BEGIN
	DROP VIEW [dbo].[Custom_ClientPhoneNumbers]
END
GO

CREATE VIEW [dbo].[Custom_ClientPhoneNumbers]
AS
SELECT ClientID, 
WholeName, 
dbo.Custom_NumberFromPhoneNumber(HomePhone) AS 'HomePhone', 
dbo.Custom_NumberFromPhoneNumber(Mobile) AS 'Mobile', 
dbo.Custom_NumberFromPhoneNumber(OtherPhone) AS 'OtherPhone', 
dbo.Custom_NumberFromPhoneNumber(WorkPhone) AS 'WorkPhone',
'Client' AS 'Type'
FROM Clients

UNION

SELECT ClientID, 
WholeName, 
dbo.Custom_NumberFromPhoneNumber(HomePhone) AS 'HomePhone', 
dbo.Custom_NumberFromPhoneNumber(Mobile) AS 'Mobile', 
NULL AS 'OtherPhone',
dbo.Custom_NumberFromPhoneNumber(WorkPhone) AS 'WorkPhone',
'LeadClient' AS 'Type'
FROM LeadClient

GO



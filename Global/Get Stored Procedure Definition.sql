IF OBJECT_ID('Custom_GetProcedureDef') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_GetProcedureDef
END
GO

CREATE PROCEDURE dbo.Custom_GetProcedureDef(
	@procedure_name nvarchar(128)
) 
AS
BEGIN
	SELECT o.name,o.object_id,s.definition 
	FROM sys.sql_modules s 
	JOIN sys.objects o 
		ON s.object_id = o.object_id
	WHERE o.name LIKE @procedure_name
END
GO
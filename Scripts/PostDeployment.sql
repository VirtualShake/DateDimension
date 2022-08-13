/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

Execute dbo.AddDimensionDate '1/1/2010', '12/31/2020'

Execute dbo.AddDimensionDateFY '1/1/2010', '12/31/2020'	

Execute dbo.AddDimensionTime

Execute dbo.AddDimensionTime2

Execute dbo.AddDimensionTimeFrame
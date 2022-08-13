/*************************************************************************************************
**	Procedure Name: AddDimensionTimeFrame
**	----------------------------------------------------------------------------------------------
**	Purpose:		Adds record(s) to the TimeFrame dimension table for all timeframes 
**					inclusive of those passed in
**	----------------------------------------------------------------------------------------------
**
**	Modifications
**	----------------------------------------------------------------------------------------------
**	Modified by			Date			Comment
**	----------------------------------------------------------------------------------------------
**	Stephen Shake		12-Apr-2016		Created
**
**************************************************************************************************/
Create Procedure dbo.AddDimensionTimeFrame
(
	@lowerBoundTime int = 1,		
	@upperBoundTime int = 1440
)
As

Set NoCount On;

--Use a CTE to create a date iterator 
With CalculatedTime AS
(
	Select @lowerBoundTime Tme

	Union All

	Select (Tme + 1)
	From CalculatedTime 
	Where ((Tme + 1) <= @upperBoundTime)
)

Insert Into Dimension.TimeFrame
Select 
	Tme as TimeFrameKey,
	RIGHT('0' + Cast((Tme / 60) as varchar(2)), 2) + ':'
		+ RIGHT('0' + Cast((Tme % 60) as varchar(2)), 2) as TimeFrame,
	Case 
		When Cast((Tme / 60) as varchar(2)) = 1 Then '1 Hour'
		When Cast((Tme / 60) as varchar(2)) > 1 Then Cast((Tme / 60) as varchar(2)) + ' Hours'
		Else ''
	End +
		Case 
			When Cast((Tme % 60) as varchar(2)) = 1 Then ' 1 Minute'
			When Cast((Tme % 60) as varchar(2)) > 1
				Then ' ' + Cast((Tme % 60) as varchar(2)) + ' Minutes'
			Else ''
		End as TimeFrameDescription,
	Cast(Cast((Tme / 60) as varchar(2)) as decimal) 
		+ Cast(Cast((Tme % 60) as varchar(2)) as decimal) / 60 as TimeFrameDecimal
From 
	CalculatedTime

OPTION (MAXRECURSION 0)



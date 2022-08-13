/*************************************************************************************************
**	Procedure Name: AddDimensionTime
**	----------------------------------------------------------------------------------------------
**	Purpose:		Adds record(s) to the Time dimension table for all times inclusive of 
**					those passed in
**	----------------------------------------------------------------------------------------------
**
**	Modifications
**	----------------------------------------------------------------------------------------------
**	Modified by			Date			Comment
**	----------------------------------------------------------------------------------------------
**	Stephen Shake		12-Apr-2016		Created
**
**************************************************************************************************/
Create Procedure dbo.AddDimensionTime
(
	@lowerBoundTime int = 0,
	@upperBoundTime int = 1439
)
As

Set NoCount On;

--Use a CTE to create a time iterator 
With CalculatedTime AS
(
	Select @lowerBoundTime Tme

	Union All

	Select (Tme + 1)
	From CalculatedTime 
	Where ((Tme + 1) <= @upperBoundTime)
)

Insert Into Dimension.Time
Select 
	Tme as TimeFrameKey,
	Case 
		When (Tme / 60) > 12 Then (Tme / 60) - 12
		Else (Tme / 60)
	End as HourOfDay12, 
	Tme / 60 as HourOfDay24,
	Case 
		When (Tme / 60) > 11 Then 'PM'
		Else 'AM'
	End as AMPM, 
	Tme % 60 as MinuteOfHour,
	Tme as MinuteOfDay,
	RIGHT('0' + Cast(Case 
		When (Tme / 60) > 12 Then (Tme / 60) - 12 Else (Tme / 60) End as varchar(2)), 2) 
		+ ':' + RIGHT('0' + Cast((Tme % 60) as varchar(2)), 2) as Time12,
	RIGHT('0' + Cast(Case 
		When (Tme / 60) > 12 Then (Tme / 60) - 12 Else (Tme / 60) End as varchar(2)), 2) 
		+ ':' + RIGHT('0' + Cast((Tme % 60) as varchar(2)), 2) 
		+ ' ' + Case When (Tme / 60) > 11 Then 'PM' Else 'AM' End as Time12AMPM,
	RIGHT('0' + Cast((Tme / 60) as varchar(2)), 2) + ':'
		+ RIGHT('0' + Cast((Tme % 60) as varchar(2)), 2) as Time24
From 
	CalculatedTime

OPTION (MAXRECURSION 0)


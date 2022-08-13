/*************************************************************************************************
**	Procedure Name: AddDimensionTime2
**	----------------------------------------------------------------------------------------------
**	Purpose:		Adds record(s) to the Time2 dimension table for all times inclusive of 
**					those passed in
**	----------------------------------------------------------------------------------------------
**
**	Modifications
**	----------------------------------------------------------------------------------------------
**	Modified by			Date			Comment
**	----------------------------------------------------------------------------------------------
**	Stephen Shake		21-Mar-2017		Created
**
**************************************************************************************************/
Create Procedure dbo.AddDimensionTime2
(
	@lowerBoundTime int = 0,
	@upperBoundTime int = 86399
)
as 

Set NoCount On

;--Use a CTE to create a time iterator 
With CalculatedTime AS
(
	Select @lowerBoundTime Tme

	Union All

	Select (Tme + 1)
	From CalculatedTime 
	Where ((Tme + 1) <= @upperBoundTime)
)

Insert Into Dimension.Time2
Select 
	Tme as TimeKey,
	Case 
		When (Tme / 3600) > 12 Then (Tme / 3600) - 12
		Else (Tme / 3600)
	End as HourOfDay12,
	Tme/60/60 % 24 as HourOfDay24,
	Case 
		When (Tme/60/60 % 24) > 11 Then 'PM'
		Else 'AM'
	End as AMPM, 
	Tme/60 % 60 as MinuteOfHour,
	Tme/60 as MinuteOfDay,
	Tme % 60 as SecondOfMinute,
	Tme % 3600 as SecondOfHour,
	Tme as SecondOfDay,
	Right('00' + Cast(
		Case 
			When (Tme / 3600) > 12 Then (Tme / 3600) - 12
			Else (Tme / 3600)
		End as varchar(5)), 2)
		+ ':' + Right('00' + Cast(Tme/60 % 60 as varchar(5)), 2)
		+ ':' + Right('00' + Cast(Tme % 60 as varchar(5)), 2) as Time12,

	Right('00' + Cast(
		Case 
			When (Tme / 3600) > 12 Then (Tme / 3600) - 12
			Else (Tme / 3600)
		End as varchar(5)), 2)
		+ ':' + Right('00' + Cast(Tme/60 % 60 as varchar(5)), 2)
		+ ':' + Right('00' + Cast(Tme % 60 as varchar(5)), 2) + ' ' 
		+ Case 
			When (Tme/60/60 % 24) > 11 Then 'PM'
			Else 'AM'
		End 
		as Time12AMPM,
	Right('00' + Cast(Tme/60/60 % 24 as varchar(5)), 2)
		+ ':' + Right('00' + Cast(Tme/60 % 60 as varchar(5)), 2)
		+ ':' + Right('00' + Cast(Tme % 60 as varchar(5)), 2) as Time24
From CalculatedTime 

OPTION (MAXRECURSION 0)

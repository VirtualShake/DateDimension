/*************************************************************************************************
**	Procedure Name: AddDimensionDateFY
**	----------------------------------------------------------------------------------------------
**	Purpose:		Adds record(s) to the Fiscal Date dimension table for all dates inclusive 
**					of those passed in
**	----------------------------------------------------------------------------------------------
**
**	Modifications
**	----------------------------------------------------------------------------------------------
**	Modified by			Date			Comment
**	----------------------------------------------------------------------------------------------
**	Stephen Shake		17-Mar-2016		Created
**
**************************************************************************************************/
Create Procedure dbo.AddDimensionDateFY 
(
	@lowerBoundDate datetime,		--The date from which to begin adding to the Date table
	@upperBoundDate datetime,		--The last date at which to stop adding to the date table
	@fiscalFirstMonth tinyint = 1,	--The fiscal month to calculate FY date values
	@isFyYearBehind bit = 0			--Flag to determine if FY is a year behind the year in which it ends
)
As

Set NoCount On;

--Use a CTE to create a date iterator 
With CalculatedDate AS
(
	Select @lowerBoundDate CalendarDate

	Union All

	Select (CalendarDate + 1)
	From CalculatedDate 
	Where ((CalendarDate + 1) <= @upperBoundDate)
)

Insert Into Dimension.DateFY

Select 
	Cast(CONVERT(varchar(20),CalendarDate, 112) as int) as DateId,
	Cast(@fiscalFirstMonth as varchar(2)) + Case @isFyYearBehind When 0 Then 'A' Else 'B' End as FYSetKey,
	--Fiscal Information
	dbo.FYDateName('FY_Year', CalendarDate, @fiscalFirstMonth, @isFyYearBehind) as FYName,
	'Fiscal Year ' + dbo.FYDateName('FY_Year', CalendarDate, @fiscalFirstMonth, @isFyYearBehind) as FYLongName,
	'FY ' + Right(dbo.FYDateName('FY_Year', CalendarDate, @fiscalFirstMonth, @isFyYearBehind), 2) as FYShortName,
	Right(dbo.FYDateName('FY_Year', CalendarDate, @fiscalFirstMonth, @isFyYearBehind), 2) as FYAbbr,
	Cast(dbo.FYDateName('FY_FirstDay', CalendarDate, @fiscalFirstMonth, @isFyYearBehind) as Date) as FYFDY,
	Cast(dbo.FYDateName('FY_LastDay', CalendarDate, @fiscalFirstMonth, @isFyYearBehind) as Date) as FYLDY,
	dbo.FYDateName('FY_Year', CalendarDate, @fiscalFirstMonth, @isFyYearBehind) + 'Q' + dbo.FYDateName('FY_Quarter', CalendarDate, @fiscalFirstMonth, @isFyYearBehind) as FYQKey,
	'Fiscal Quarter ' + dbo.FYDateName('FY_Quarter', CalendarDate, @fiscalFirstMonth, @isFyYearBehind) as FYQName,
	'Fiscal Quarter ' + dbo.FYDateName('FY_Quarter', CalendarDate, @fiscalFirstMonth, @isFyYearBehind) + ', ' + dbo.FYDateName('FY_Year', CalendarDate, @fiscalFirstMonth, @isFyYearBehind) as FYQLongName,
	'FQ' + dbo.FYDateName('FY_Quarter', CalendarDate, @fiscalFirstMonth, @isFyYearBehind) as FYQAbbr,
	Cast(dbo.FYDateName('FY_QFirstDay', CalendarDate, @fiscalFirstMonth, @isFyYearBehind) as Date) as FYQBeg,
	Cast(dbo.FYDateName('FY_QLastDay', CalendarDate, @fiscalFirstMonth, @isFyYearBehind) as Date) as FYQEnd,
	dbo.FYDateName('FY_Quarter', CalendarDate, @fiscalFirstMonth, @isFyYearBehind) as FYQofYear,
	dbo.FYDateName('FY_Year', CalendarDate, @fiscalFirstMonth, @isFyYearBehind) + Right('000' + dbo.FYDateName('FY_Period', CalendarDate, @fiscalFirstMonth, @isFyYearBehind), 2) as FYPerKey,
	DateName(mm, CalendarDate) + ' (' + dbo.FYDateName('FY_Period', CalendarDate, @fiscalFirstMonth, @isFyYearBehind) + ')' as FYPerName,
	dbo.FYDateName('FY_Period', CalendarDate, @fiscalFirstMonth, @isFyYearBehind) as FYPerOY,
	dbo.FYDateName('FY_Year', CalendarDate, @fiscalFirstMonth, @isFyYearBehind) + 'W' + dbo.FYDateName('FY_Week', CalendarDate, @fiscalFirstMonth, @isFyYearBehind) as FYWKey,
	'Fiscal Week ' + dbo.FYDateName('FY_Week', CalendarDate, @fiscalFirstMonth, @isFyYearBehind) as FYWName,
	'Fiscal Week ' + dbo.FYDateName('FY_Week', CalendarDate, @fiscalFirstMonth, @isFyYearBehind) + ', ' + dbo.FYDateName('FY_Year', CalendarDate, @fiscalFirstMonth, @isFyYearBehind) as FYWLongName,
	'F Wk ' + dbo.FYDateName('FY_Week', CalendarDate, @fiscalFirstMonth, @isFyYearBehind) as FYWAbbr,
	'Fiscal Week ' + dbo.FYDateName('FY_Week', CalendarDate, @fiscalFirstMonth, @isFyYearBehind) + ', ' + dbo.FYDateName('FY_Year', CalendarDate, @fiscalFirstMonth, @isFyYearBehind)+
		' (' + Left(Convert(varchar(15), Dateadd(day, 1-Datepart(dw, CalendarDate), CalendarDate), 1), 5) + ' - ' +
		Left(Convert(varchar(15), Dateadd(day, 7-Datepart(dw, CalendarDate), CalendarDate), 1), 5)  + ')' as FWDesc,
	dbo.FYDateName('FY_Week', CalendarDate, @fiscalFirstMonth, @isFyYearBehind) as FYWOY,
	dbo.FYDateName('FY_Day', CalendarDate, @fiscalFirstMonth, @isFyYearBehind) as FYDOY
From CalculatedDate

OPTION (MAXRECURSION 0)


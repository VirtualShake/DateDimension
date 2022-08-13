/*************************************************************************************************
**	Procedure Name: AddDimensionDate
**	----------------------------------------------------------------------------------------------
**	Purpose:		Adds record(s) to the Date dimension table for all dates inclusive of those
**					passed in
**	----------------------------------------------------------------------------------------------
**
**	Modifications
**	----------------------------------------------------------------------------------------------
**	Modified by			Date			Comment
**	----------------------------------------------------------------------------------------------
**	Stephen Shake		15-Oct-2014		Created
**
**************************************************************************************************/
Create Procedure dbo.AddDimensionDate 
(
	@lowerBoundDate datetime,		--The date from which to begin adding to the Date table
	@upperBoundDate datetime,		--The last date at which to stop adding to the date table
	@fiscalFirstMonth tinyint = 1,	--The fiscal month to calculate FY date values
	@isFyYearBehind bit = 0,		--Flag to determine if FY is a year behind the year in which it ends
	@noDaysForLastWeek tinyint = 7	--Number of days in last week of year to determine if week is part of 
									--  current year or start of next year
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

Insert Into Dimension.[Date]

Select 
	Cast(CONVERT(varchar(20),CalendarDate, 112) as int) as DateId,
	--Year Information
	Datename(yyyy, CalendarDate) as YName,
	Right(Datename(yyyy, CalendarDate), 2) as YAbbr,
	Cast(Dateadd(yy, Datediff(yy,0,CalendarDate), 0) as Date) as YBeg,
	Cast(Dateadd(yy, Datediff(yy, -1, CalendarDate), -1) as Date) as YEnd,
	Datediff(ww, Dateadd(yy, Datediff(yy, 0, CalendarDate), 0), Dateadd(yy, Datediff(yy, -1, CalendarDate), -1)) + 1 as YNoWeeks,
	Datediff(dd, Dateadd(yy, Datediff(yy, 0, CalendarDate), 0), Dateadd(yy, Datediff(yy, -1, CalendarDate), -1)) + 1 as YNoDays,
	--Quarter Information
	Cast(Datename(yyyy, CalendarDate) + Datename(qq, CalendarDate) as int) as QKey,
	'Quarter ' + Datename(qq, CalendarDate) as QName,
	'Quarter ' + Datename(qq, CalendarDate) + ', ' + Datename(yyyy, CalendarDate) as QLongName,
	'Q' + Cast(Datepart(q, CalendarDate) as varchar(10)) as QAbbr,
	Cast(Dateadd(qq, Datediff(qq, 0, CalendarDate), 0) as Date) as QBeg,
	Cast(Dateadd(qq, Datediff(qq, -1, CalendarDate), -1) as Date) as QEnd,
	Datediff(dd, Dateadd(qq, Datediff(qq, 0, CalendarDate), 0), Dateadd(qq, Datediff(qq, -1, CalendarDate), -1)) + 1 as QNoDays,
	Datename(qq, CalendarDate) as QofYear,
	--Month Information
	Cast(Left(Convert(varchar(10), CalendarDate, 112), 6) as int) as MKey,
	DateName(mm, CalendarDate) as MName,
	DateName(mm, CalendarDate)+', '+DateName(yyyy, CalendarDate) as MLongName,
	Left(DateName(m, CalendarDate), 3) as MAbbr,
	Left(Convert(varchar(10), CalendarDate, 120), 7) as MLabel,
	Cast(Dateadd(mm, Datediff(mm, 0, CalendarDate), 0) as Date) as MBeg,
	Cast(Dateadd(mm, Datediff(mm, -1, CalendarDate), -1) as Date) as MEnd,
	Datediff(dd, Dateadd(mm, Datediff(mm, 0, CalendarDate), 0), Dateadd(mm, Datediff(mm, -1, CalendarDate), -1)) + 1 as MNoDays,
	Month(CalendarDate) as MOY,
	Case 
		When Datepart(m, CalendarDate) In (1,4,7,10) Then 1
		When Datepart(m, CalendarDate) In (2,5,8,11) Then 2
		When Datepart(m, CalendarDate) In (3,6,9,12) Then 3
	End as MOQ,
	--Week Information
	Cast(Case When Right('000'+Datename(ww, CalendarDate), 2) > 52 
		Then Case When dbo.SplitWeekDays(CalendarDate) < @noDaysForLastWeek
				Then Cast(Datename(yyyy, CalendarDate) + 1 as char(4)) + '01' 
				Else Datename(yyyy, CalendarDate) + Right('000'+Datename(ww, CalendarDate), 2)
			End
			Else Datename(yyyy, CalendarDate) + Right('000'+Datename(ww, CalendarDate), 2)
	End as int) as WKey,
	Case When Right('000'+Datename(ww, CalendarDate), 2) > 52 
		Then Case When dbo.SplitWeekDays(CalendarDate) < @noDaysForLastWeek
				Then 'Week 1' 
				Else 'Week '+DateName(ww, CalendarDate)
			End
			Else 'Week '+DateName(ww, CalendarDate)
	End as WName,
	Case When Right('000'+Datename(ww, CalendarDate), 2) > 52 
		Then Case When dbo.SplitWeekDays(CalendarDate) < @noDaysForLastWeek
				Then 'Week 1, ' + Cast(Datename(yyyy, CalendarDate) + 1 as char(4))
				Else 'Week ' + DateName(ww, CalendarDate) + ', ' + Cast(Datename(yyyy, CalendarDate) + 1 as char(4))
			End
			Else 'Week ' + DateName(ww, CalendarDate) + ', ' + Cast(Datename(yyyy, CalendarDate) + 1 as char(4))
	End as WLongName,
	Case When Right('000'+Datename(ww, CalendarDate), 2) > 52 
		Then Case When dbo.SplitWeekDays(CalendarDate) < @noDaysForLastWeek
				Then 'Wk 1' 
				Else 'Wk ' + DateName(ww, CalendarDate)
			End
			Else 'Wk ' + DateName(ww, CalendarDate)
	End as WAbbr,
	Case When Right('000'+Datename(ww, CalendarDate), 2) > 52 
		Then Case When dbo.SplitWeekDays(CalendarDate) < @noDaysForLastWeek
				Then 'Week 1, ' + Cast(Datename(yyyy, CalendarDate) + 1 as char(4))
				Else 'Week ' + DateName(ww, CalendarDate) + ', ' + Cast(Datename(yyyy, CalendarDate) + 1 as char(4))
			End
			Else 'Week ' + DateName(ww, CalendarDate) + ', ' + Cast(Datename(yyyy, CalendarDate) + 1 as char(4))
	End + ' (' + Left(Convert(varchar(15), Dateadd(day, 1-Datepart(dw, CalendarDate), CalendarDate), 1), 5) +' - '+
		Left(Convert(varchar(15), Dateadd(day, 7-Datepart(dw, CalendarDate), CalendarDate), 1), 5)  + ')' as WLongDesc,
	Case When Right('000'+Datename(ww, CalendarDate), 2) > 52 
		Then Case When dbo.SplitWeekDays(CalendarDate) < @noDaysForLastWeek
				Then 'Week 1' 
				Else 'Week '+DateName(ww, CalendarDate)
			End
			Else 'Week '+DateName(ww, CalendarDate)
	End + ' (' + Left(Convert(varchar(15), Dateadd(day, 1-Datepart(dw, CalendarDate), CalendarDate), 1), 5) +' - '+
		Left(Convert(varchar(15), Dateadd(day, 7-Datepart(dw, CalendarDate), CalendarDate), 1), 5)  + ')' as WShortDesc,
	Cast(Dateadd(day, 1 - Datepart(dw, CalendarDate), CalendarDate) as Date) as WBeg,
	Cast(Dateadd(day, 7 - Datepart(dw, CalendarDate), CalendarDate) as Date) as WEnd,
	Case 
		When Dateadd(mm, Datediff(mm, -1, CalendarDate), -1) > Dateadd(day, 7-Datepart(dw, CalendarDate), CalendarDate)
		Then Cast(Dateadd(day, 7-Datepart(dw, CalendarDate), CalendarDate) as Date)
		Else Cast(Dateadd(mm, Datediff(mm, -1, CalendarDate), -1) as Date)
	End as WEndS,
	Datediff(dd, Dateadd(day, 1-Datepart(dw, CalendarDate), CalendarDate), Dateadd(day, 7-Datepart(dw, CalendarDate), CalendarDate)) + 1 as WNoDays,
	dbo.SplitWeekDays(CalendarDate) as WNoDays_S,
	Case When Right('000'+Datename(ww, CalendarDate), 2) > 52 
		Then Case When dbo.SplitWeekDays(CalendarDate) < @noDaysForLastWeek
				Then 1 
				Else Datepart(ww, CalendarDate)
			End
			Else Datepart(ww, CalendarDate)
	End as WOY,
	Datediff(week, convert(varchar(6), CalendarDate, 112) + '01', CalendarDate) + 1 as WOM,
	--Day and Date Information
	DateName(dw, CalendarDate) as DName,
	Left(DateName(dw, CalendarDate), 3) as DAbbr,
	Cast(CalendarDate as date) as DDate,
	DateName(mm, CalendarDate)+' '+DateName(dd, CalendarDate)+', '+DateName(yyyy, CalendarDate) as DFullDate,
	DateName(dw, CalendarDate)+', '+DateName(mm, CalendarDate)+' '+DateName(dd, CalendarDate)+', '+DateName(yyyy, CalendarDate) as DLongDate,
	Convert(varchar(20), CalendarDate, 107) as DAbbrDate,
	Convert(varchar(20), CalendarDate, 101) as DShortDate,
	Convert(varchar(20), CalendarDate, 105) as DEuroDate,
	Datepart(dy, CalendarDate) as DOY,
	DateDiff(dd, Dateadd(qq, Datediff(qq, 0, CalendarDate), 0), CalendarDate)+1 as DOQ,
	Datepart(dd, CalendarDate) as DOM,
	Datepart(dw, CalendarDate) as DOW,
	null as AltDayName,
	--Flag Information
	0 as IsCur,
	dbo.IsDateFlagged(CalendarDate, 'LY') as IsLY,
	dbo.IsDateFlagged(CalendarDate, 'FDY') as IsFDY,
	dbo.IsDateFlagged(CalendarDate, 'FDQ') as IsFDQ,
	dbo.IsDateFlagged(CalendarDate, 'FDM') as IsFDM,
	dbo.IsDateFlagged(CalendarDate, 'FDW') as IsFDW,
	dbo.IsDateFlagged(CalendarDate, 'LDY') as IsLDY,
	dbo.IsDateFlagged(CalendarDate, 'LDQ') as IsLDQ,
	dbo.IsDateFlagged(CalendarDate, 'LDM') as IsLDM,
	dbo.IsDateFlagged(CalendarDate, 'LDW') as IsLDW,
	dbo.IsDateFlagged(CalendarDate, 'WD') as IsWD,
	dbo.IsDateFlagged(CalendarDate, 'SW') as IsSW,
	dbo.IsDateFlagged(CalendarDate, 'HOL') as IsHOL
From CalculatedDate

OPTION (MAXRECURSION 0)


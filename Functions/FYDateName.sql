/*************************************************************************************************
**	Function Name: FYDateName
**	----------------------------------------------------------------------------------------------
**	Purpose:		Determines the appropriate Fiscal Year assciated with the date
**					Date Part Names that can be used include:
**						FY_Year = Fiscal Year 
**						FY_Quarter = Fiscal Quarter
**						FY_Period = Fiscal Month/Period
**						FY_Week = Fiscal Week
**						FY_Day = Fiscal Day
**						FY_FirstDay = First Day of Fiscal Year
**						FY_LastDay = Last Day of Fiscal Year
**	----------------------------------------------------------------------------------------------
**	Output:		Varchar(50) - The value as a string
**	----------------------------------------------------------------------------------------------
**
**	Modifications
**	----------------------------------------------------------------------------------------------
**	Modified by			Date			Comment
**	----------------------------------------------------------------------------------------------
**	Stephen Shake		15-Oct-2014		Created
**	
**************************************************************************************************/
Create Function FYDateName
(
	@fyDatePartName varchar(20),
	@date datetime,
	@fiscalFirstMonth tinyint,
	@isFyYearBehind bit
)
Returns varchar(50) As

Begin
	Declare @result varchar(50)

	Declare 
		@curYear int,
		@curMonth int,
		@fyYear int,
		@fyYear_Start int,
		@fyFirstDay date,
		@fyLastDay date

	Select 
		@curYear = Year(@date),
		@curMonth = Month(@date)

	Select 
		@fyYear = Case When @curMonth >= @fiscalFirstMonth 
			Then 
				Case @isFyYearBehind When 1 Then @curYear Else @curYear + 1 End
			Else
				Case @isFyYearBehind When 1 Then @curYear - 1 Else @curYear End
		End
	Select
		@fyYear_Start = Case When @curMonth >= @fiscalFirstMonth
			Then 
				Case @isFyYearBehind When 1 Then @fyYear Else @curYear End
			Else
				Case @isFyYearBehind When 1 Then @curYear - 1 Else @fyYear - 1 End
		End

	Select 
		@fyFirstDay = Cast(Cast(@fiscalFirstMonth as varchar(5)) + '/1/' + Cast(@fyYear_Start as varchar(5)) as date),
		@fyLastDay = DateAdd(dd, -1, Cast(Cast(@fiscalFirstMonth as varchar(5)) + '/1/' + Cast(@fyYear_Start + 1 as varchar(5)) as date))


	Select @result = Case @fyDatePartName
		When 'FY_Year' Then Cast(@fyYear as varchar(50))
		When 'FY_Quarter' Then Case 
								When DateDiff(Month, @fyFirstDay, @date) + 1 In (1, 2, 3) Then '1'
								When DateDiff(Month, @fyFirstDay, @date) + 1 In (4, 5, 6) Then '2'
								When DateDiff(Month, @fyFirstDay, @date) + 1 In (7, 8, 9) Then '3'
								Else '4'
							End
		When 'FY_QFirstDay' Then Case 
								When DateDiff(Month, @fyFirstDay, @date) + 1 In (1, 2, 3)
									Then Convert(Varchar(50), @fyFirstDay, 101)
								When DateDiff(Month, @fyFirstDay, @date) + 1 In (4, 5, 6)
									Then Convert(Varchar(50), Dateadd(mm, 3, @fyFirstDay), 101)
								When DateDiff(Month, @fyFirstDay, @date) + 1 In (7, 8, 9)
									Then Convert(Varchar(50), Dateadd(mm, 6, @fyFirstDay), 101)
								Else Convert(Varchar(50), Dateadd(mm, 9, @fyFirstDay), 101)
							End
		When 'FY_QLastDay' Then Case 
								When DateDiff(Month, @fyFirstDay, @date) + 1 In (1, 2, 3)
									Then Convert(Varchar(50), DateAdd(dd, -1, Dateadd(mm, 3, @fyFirstDay)), 101)
								When DateDiff(Month, @fyFirstDay, @date) + 1 In (4, 5, 6)
									Then Convert(Varchar(50), DateAdd(dd, -1, Dateadd(mm, 6, @fyFirstDay)), 101)
								When DateDiff(Month, @fyFirstDay, @date) + 1 In (7, 8, 9)
									Then Convert(Varchar(50), DateAdd(dd, -1, Dateadd(mm, 9, @fyFirstDay)), 101)
								Else Convert(Varchar(50), DateAdd(dd, -1, Dateadd(mm, 12, @fyFirstDay)), 101)
							End
		When 'FY_Period' Then Cast(DateDiff(Month, @fyFirstDay, @date) + 1 as varchar(5))
		When 'FY_Week' Then Cast(DateDiff(Week, @fyFirstDay, @date) + 1 as varchar(5))
		When 'FY_Day' Then Cast(DateDiff(Day, @fyFirstDay, @date) + 1 as varchar(5))
		When 'FY_FirstDay' Then Convert(Varchar(50), @fyFirstDay, 101)
		When 'FY_LastDay' Then Convert(Varchar(50), @fyLastDay, 101)

	End

	Return @result
End
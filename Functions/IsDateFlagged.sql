/*************************************************************************************************
**	Function Name: IsDateFlagged
**	----------------------------------------------------------------------------------------------
**	Purpose:		Determines if a specified date should be flagged given the specified flag type.
**					Flag types that can be used include:
**						FDY = First Day of the Year 
**						LDY = Last Day of the Year 
**						FDQ = First Day of the Quarter
**						LDQ = Last Day of the Quarter
**						FDM = First Day of the Month 
**						LDM = Last Day of the Month
**						FDW = First Day of the Week
**						LDW = Last Day of the Week
**						HOL = Holiday (U.S Major Holidays only)
**						WD = Week Day
**						LY = Leap Year
**						SW = Split Week
**	----------------------------------------------------------------------------------------------
**	Output:		Bit Value - 1 if the flag is set, 0 if not
**	----------------------------------------------------------------------------------------------
**
**	Modifications
**	----------------------------------------------------------------------------------------------
**	Modified by			Date			Comment
**	----------------------------------------------------------------------------------------------
**	Stephen Shake		15-Oct-2014		Created
**	Stephen Shake		21-Oct-2014		Added Day After Thanksgiving to Holiday List
**************************************************************************************************/
Create Function IsDateFlagged
(
	@date    datetime,
	@checkFlag varchar(10)
)
Returns Bit As

Begin
	Declare @result bit

	Declare 
		@curYear char(4),
		@lastKnownMonday datetime,
		@lastKnownSaturday datetime,
		@FDM datetime,
		@LDM datetime
	
	Select 
		@lastKnownMonday = '1/29/1990',
		@lastKnownSaturday = '1/27/1990',
		@curYear = DateName(yy, @date),
		@FDM = Cast(Dateadd(mm, Datediff(mm, 0, @date), 0) as Datetime),
		@LDM = Cast(Dateadd(mm, Datediff(mm, -1, @date), -1) as Date)

	Select @result = Case @checkFlag
		When 'FDY' Then Case When @date = cast('1/1/'+@curYear as datetime) Then 1 ELse 0 End
		When 'LDY' Then Case When @date = cast('12/31/'+@curYear as datetime) Then 1 ELse 0 End

		When 'FDQ' Then Case When @date = cast('1/1/'+@curYear as datetime) Then 1 
							 When @date = cast('4/1/'+@curYear as datetime) Then 1 
							 When @date = cast('7/1/'+@curYear as datetime) Then 1 
							 When @date = cast('10/1/'+@curYear as datetime) Then 1 ELse 0 End
		When 'LDQ' Then Case When @date = cast('3/31/'+@curYear as datetime) Then 1 
							 When @date = cast('6/30/'+@curYear as datetime) Then 1 
							 When @date = cast('9/30/'+@curYear as datetime) Then 1 
							 When @date = cast('12/31/'+@curYear as datetime) Then 1 ELse 0 End

		When 'FDM' Then Case When @date = @FDM Then 1 ELse 0 End
		When 'LDM' Then Case When @date = @LDM Then 1 ELse 0 End

		When 'FDW' Then Case When datepart(dw, @date) = 1 Then 1 ELse 0 End
		When 'LDW' Then Case When datepart(dw, @date) = 7 Then 1 ELse 0 End

		When 'WD' Then Case When datepart(dw, @date) = 2 Then 1 
							When datepart(dw, @date) = 3 Then 1 
							When datepart(dw, @date) = 4 Then 1 
							When datepart(dw, @date) = 5 Then 1 
							When datepart(dw, @date) = 6 Then 1 ELse 0 End

		When 'HOL' Then Case When @date = cast('1/1/'+@curYear as datetime) Then 1 --New Years
							 When @date = Dateadd(DD, Datediff(DD, @lastKnownMonday, @LDM) / 7 * 7, @lastKnownMonday)
								and Datepart(mm, @date) = 5 Then 1 --Memorial Day
							 When @date = cast('7/4/'+@curYear as datetime) Then 1 --Independence Day
							 When @date = Dateadd(dd, Datediff(dd, @lastKnownMonday, Dateadd(dd, (1 * 7) -1, @fdm)) / 7 * 7, @lastKnownMonday)
								and Datepart(mm, @date) = 9 Then 1 --Labor Day
							 When @date = Dateadd(DD, Datediff(DD, @lastKnownSaturday, @LDM) / 7 * 7, @lastKnownSaturday - 2)
								and Datepart(mm, @date) = 11 Then 1 --Thenksgiving Day
							 When @date = Dateadd(DD, Datediff(DD, @lastKnownSaturday, @LDM) / 7 * 7, @lastKnownSaturday - 1)
								and Datepart(mm, @date) = 11 Then 1 --Day After Thenksgiving
							 When @date = cast('12/25/'+@curYear as datetime) Then 1 --Christmas
							 ELse 0 End

		When 'LY' Then Case When (Year(@date)%4 = 0 and Year(@date)%100 != 0) Then 1
							When Year(@date)%400 = 0 Then 1
							Else 0 End

		When 'SW' Then Case When Month(Dateadd(day, 1-Datepart(dw, @date), @date)) 
								<> Month(Dateadd(day, 7-Datepart(dw, @date), @date)) Then 1
							Else 0 End
	End

	Return @result

End

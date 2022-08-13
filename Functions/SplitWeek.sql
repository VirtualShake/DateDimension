/*************************************************************************************************
**	Function Name:	SplitWeekDays
**	----------------------------------------------------------------------------------------------
**	Purpose:		Determines the number of days in a week 
**	----------------------------------------------------------------------------------------------
**	Output:			tinyint
**	----------------------------------------------------------------------------------------------
**
**	Modifications
**	----------------------------------------------------------------------------------------------
**	Modified by			Date			Comment
**	----------------------------------------------------------------------------------------------
**	Stephen Shake		24-Mar-2016		Created
**	
**************************************************************************************************/
Create Function SplitWeekDays
(
	@date    datetime
)
Returns TinyInt As

Begin
	Declare @result tinyint

	Select @result =
		Case 
			When Dateadd(mm, Datediff(mm, -1, @date), -1) > Dateadd(day, 7-Datepart(dw, @date), @date)
			Then 
				Case 
					When Month(Dateadd(day, 1-Datepart(dw, @date), @date)) <> Month(Dateadd(day, 7-Datepart(dw, @date), @date))
					Then Datediff(dd, Dateadd(mm, Datediff(mm, 0, @date), 0), Dateadd(day, 7-Datepart(dw, @date), @date))+1
					Else Datediff(dd, Dateadd(day, 1-Datepart(dw, @date), @date), Dateadd(day, 7-Datepart(dw, @date), @date))+1
				End		
			Else Datediff(dd, Dateadd(day, 1-Datepart(dw, @date), @date), Dateadd(mm, Datediff(mm, -1, @date), -1))+1
		End

	Return @result

End

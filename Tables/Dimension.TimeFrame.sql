CREATE TABLE [Dimension].[TimeFrame]
(
	[TimeFrameKey] INT NOT NULL, 
    [TimeFrame] CHAR(5) NOT NULL,
    [TimeFrameDescription] VARCHAR(25) NOT NULL, 
    [TimeFrameDecimal] DECIMAL(7, 4) NOT NULL, 
    CONSTRAINT PK_TimeFrame PRIMARY KEY (TimeFrameKey)

)



CREATE FUNCTION [nuuMeta].[SplitCamelCase](@x VARCHAR(8000))
RETURNS VARCHAR(8000) AS
BEGIN

	SET @x = REPLACE(@x,'_','')

	DECLARE 
		@length int = LEN(@x),
		@i int = 1,
		@Previous CHAR(1),
		@Current CHAR(1),
		@Next CHAR(1),
		@IsPreviousUpper BIT,
		@IsCurrentUpper BIT,
		@IsNextUpper BIT

	WHILE @i <= @length
	BEGIN
	
		SET @Previous = SUBSTRING(@x,@i-1,1)
		SET @Current = SUBSTRING(@x,@i,1)
		SET @Next = SUBSTRING(@x,@i+1,1)
	
		SET @IsPreviousUpper = IIF(@Previous = UPPER(@Previous) COLLATE Latin1_General_CS_AS, 1, 0)
		SET @IsCurrentUpper = IIF(@Current = UPPER(@Current) COLLATE Latin1_General_CS_AS, 1, 0)
		SET @IsNextUpper = IIF(@Next = UPPER(@Next) COLLATE Latin1_General_CS_AS, 1, 0)

		IF (@IsCurrentUpper = 1 AND (@IsNextUpper = 0 OR @IsPreviousUpper = 0) AND NULLIF(@previous,'') IS NOT NULL)
		BEGIN
		
			SET @x = STUFF(@x,@i,0,' ')
			SET @i += 1
			SET @length += 1

		END

		SET @i += 1

	END

	RETURN @x

END



CREATE FUNCTION [meta].[SplitString] (
      @InputString                  VARCHAR(MAX),
      @Delimiter                    VARCHAR(50)
)

RETURNS @Items TABLE (
      ID INT,
      Item                          VARCHAR(MAX)
)

AS
BEGIN
      IF @Delimiter = ' '
      BEGIN
            SET @Delimiter = ','
            SET @InputString = REPLACE(@InputString, ' ', @Delimiter)
      END

      IF (@Delimiter IS NULL OR @Delimiter = '')
            SET @Delimiter = ','

--INSERT INTO @Items VALUES (@Delimiter) -- Diagnostic
--INSERT INTO @Items VALUES (@InputString) -- Diagnostic

      DECLARE @Item           VARCHAR(8000)
      DECLARE @ItemList       VARCHAR(8000)
      DECLARE @DelimIndex     INT
	  DECLARE @Counter INT

      SET @ItemList = @InputString
      SET @DelimIndex = CHARINDEX(@Delimiter, @ItemList, 0)
	  SET @Counter = 1
      WHILE (@DelimIndex != 0)
      BEGIN
            SET @Item = SUBSTRING(@ItemList, 0, @DelimIndex)
            INSERT INTO @Items (ID, Item) VALUES (@Counter,@Item)

            -- Set @ItemList = @ItemList minus one less item
            SET @ItemList = SUBSTRING(@ItemList, @DelimIndex+1, LEN(@ItemList)-@DelimIndex)
            SET @DelimIndex = CHARINDEX(@Delimiter, @ItemList, 0)
			SET @Counter = @Counter + 1
      END -- End WHILE

	
      IF @Item IS NOT NULL -- At least one delimiter was encountered in @InputString
      BEGIN
            SET @Item = @ItemList
			--SET @Counter = @Counter + 1
             INSERT INTO @Items (ID, Item) VALUES (@Counter,LTRIM(@Item))
      END

      -- No delimiters were encountered in @InputString, so just return @InputString
      ELSE  INSERT INTO @Items (ID, Item) VALUES (@Counter,LTRIM(@InputString))

      RETURN

END -- End Function
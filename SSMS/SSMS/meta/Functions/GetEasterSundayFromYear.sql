
-- =============================================
CREATE FUNCTION [meta].[GetEasterSundayFromYear]
(
    @year INT
)
RETURNS date
AS
BEGIN
	DECLARE
		@a INT
		,@b INT
		,@c INT
		,@d INT
		,@e INT
		,@f INT
		,@g INT
		,@h INT
		,@i INT
		,@k INT
		,@l INT
		,@m INT
		,@n INT
		,@p INT
		,@eastersunday DATE

	SET @a = @year % 19;
	SET @b = @year / 100;
	SET @c = @year % 100;
	SET @d = @b / 4;
	SET @e = @b % 4;
	SET @f = (@b + 8) / 25;
	SET @g = (@b - @f + 1) / 3;
	SET @h = ((19 * @a) + @b - @d - @g + 15) % 30;
	SET @i = @c / 4;
	SET @k = @c % 4;
	SET @l = (32 + (2 * @e) + (2 * @i) - @h -@k) % 7;
	SET @m = (@a + (11 * @h) + (22 * @l)) / 451;
	SET @n = (@h + @l - (7 * @m) + 114) / 31;
	SET @p = ((@h + @l - (7 * @m) + 114) % 31) + 1;

	SET @eastersunday = DATEFROMPARTS(@year,@n,@p);

    RETURN @eastersunday
END
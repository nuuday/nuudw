


CREATE VIEW [cubeView_FAM].[Dim Date Periods]
AS

SELECT CP.[CalendarID],
       [Period Dummy] = [period],
       [Period] = CASE
       /*Udforming af Perioder, så nuværende og seneste periode erstattes af, eksempelvis "Current Week" og "Last Week", for kalender uger, hvor resten af ugerne vises i normal format.*/
                    WHEN [type] = 'Select date'
                         AND calendardate = CONVERT(DATE, Getdate()) THEN
                    'Today'
                    WHEN [type] = 'Select date'
                         AND Datediff(day, Getdate(), [calendardate]) = -1 THEN
                    'Yesterday'
                    WHEN [type] = 'Select week'
                         AND Cast(Year(Dateadd(day, 26 - Datepart(isoww, Getdate
                             ()),
                             Getdate()))
                             AS VARCHAR(4
                             ))
                             + Cast(Datepart(isoww, Getdate()) AS VARCHAR(2)) =
                                 Cast(Year(Dateadd(day, 26 - Datepart(isoww,
                                 calendardate),
                                 calendardate)
                                 ) AS
                                 VARCHAR(4))
                                 + Cast(Datepart(isoww, calendardate) AS VARCHAR
                                 (2))
                  THEN
                    'Current week'
                    WHEN [type] = 'Select week'
                         AND Cast(Year(Dateadd(day, 26 - Datepart(isoww, Dateadd
                             (day,
                             - 7, Getdate
                             ())),
                             Dateadd(day, - 7, Getdate()))) AS VARCHAR(4))
                             + Cast(Datepart(isoww, Dateadd(day, - 7, Getdate())
                             ) AS
                             VARCHAR(2)) =
                                 Cast(Year(Dateadd(day, 26 - Datepart(isoww,
                                 calendardate),
                                 calendardate)
                                 ) AS
                                 VARCHAR(4))
                                 + Cast(Datepart(isoww, calendardate) AS VARCHAR
                                 (2))
                  THEN
                    'Last week'
                    WHEN [type] = 'Select month'
                         AND Eomonth(calendardate) = Eomonth(Getdate()) THEN
                    'Current month'
                    WHEN [type] = 'Select month'
                         AND Eomonth(calendardate) = Eomonth(
                             Dateadd(month, -1, Getdate())) THEN
                    'Last month'
                    ELSE [period]
                  END,
       [Type],
       [TypeDK] AS [Type DK],
       [Type Sort] = [sort],
       [Period Sort] = [sort] * 10000 + Rank()
                                         OVER (
                                           partition BY [sort]
                                           ORDER BY [period] DESC)

FROM   (SELECT [calendarid],
               [Period] = CONVERT(VARCHAR, [calendardate]),
               [Type] = 'Today',
               [TypeDK] = 'I dag',
               [Sort] = 1
        FROM   [dim].[calendar]
        WHERE  calendardate = CONVERT(DATE, Getdate())
        UNION ALL
        SELECT [calendarid],
               [Period] = CONVERT(VARCHAR, [calendardate]),
               [Type] = 'Yesterday',
               [TypeDK] = 'I går',
               [Sort] = 2
        FROM   [dim].[calendar]
        WHERE  Datediff(day, Getdate(), [calendardate]) = -1
        UNION ALL
        SELECT [calendarid],
               [Period] = CONVERT(VARCHAR, [calendardate]),
               [Type] = 'Last 7 days',
               [TypeDK] = 'Sidste 7 dage',
               [Sort] = 3
        FROM   [dim].[calendar]
        WHERE  Datediff(day, Getdate(), [calendardate]) BETWEEN -6 AND 0
        UNION ALL
        SELECT [calendarid],
               [Period] = CONVERT(VARCHAR, [calendardate]),
               [Type] = 'Week to date',
               [TypeDK] = 'Uge til dato',
               [Sort] = 4
        FROM   [dim].[calendar]
        WHERE  Cast(Year(Dateadd(day, 26 - Datepart(isoww, Getdate()), Getdate()
               )) AS
               VARCHAR(4
               ))
               + Cast(Datepart(isoww, Getdate()) AS VARCHAR(2)) =
                      Cast(Year(Dateadd(day, 26 - Datepart(isoww, calendardate),
                      calendardate))
                      AS
                      VARCHAR(4))
                      + Cast(Datepart(isoww, calendardate) AS VARCHAR(2))
               AND calendardate <= CONVERT(DATE, Getdate())
        UNION ALL
        SELECT [calendarid],
               [Period] = CONVERT(VARCHAR, [calendardate]),
               [Type] = 'Current week',
               [TypeDK] = 'Denne uge',
               [Sort] = 5
        FROM   [dim].[calendar]
        WHERE  Cast(Year(Dateadd(day, 26 - Datepart(isoww, Getdate()), Getdate()
               )) AS
               VARCHAR(4
               ))
               + Cast(Datepart(isoww, Getdate()) AS VARCHAR(2)) =
                      Cast(Year(Dateadd(day, 26 - Datepart(isoww, calendardate),
                      calendardate)) AS
                      VARCHAR(4))
                      + Cast(Datepart(isoww, calendardate) AS VARCHAR(2))
        UNION ALL
        SELECT [calendarid],
               [Period] = CONVERT(VARCHAR, [calendardate]),
               [Type] = 'Last week',
               [TypeDK] = 'Sidste uge',
               [Sort] = 6
        FROM   [dim].[calendar]
        WHERE  Cast(Year(Dateadd(day, 26 - Datepart(isoww, Dateadd(day, - 7,
               Getdate())
               )
               ,
               Dateadd(day, - 7, Getdate()))) AS VARCHAR(4))
               + Cast(Datepart(isoww, Dateadd(day, - 7, Getdate())) AS VARCHAR(2
               )) =
                      Cast(Year(Dateadd(day, 26 - Datepart(isoww, calendardate),
                      calendardate)) AS
                      VARCHAR(4))
                      + Cast(Datepart(isoww, calendardate) AS VARCHAR(2))
        UNION ALL
        SELECT [calendarid],
               [Period] = CONVERT(VARCHAR, [calendardate]),
               [Type] = 'Last 14 days',
               [TypeDK] = 'Sidste 14 dage',
               [Sort] = 7
        FROM   [dim].[calendar]
        WHERE  Datediff(day, Getdate(), [calendardate]) BETWEEN -13 AND 0
               AND calendardate <= CONVERT(DATE, Getdate())
        UNION ALL
        SELECT [calendarid],
               [Period] = CONVERT(VARCHAR, [calendardate]),
               [Type] = 'Month to date',
               [TypeDK] = 'Måned til dato',
               [Sort] = 8
        FROM   [dim].[calendar]
        WHERE  Eomonth(calendardate) = Eomonth(Getdate())
               AND calendardate <= CONVERT(DATE, Getdate())
        UNION ALL
        SELECT [calendarid],
               [Period] = CONVERT(VARCHAR, [calendardate]),
               [Type] = 'Current month',
               [TypeDK] = 'Denne Måned',
               [Sort] = 9
        FROM   [dim].[calendar]
        WHERE  Eomonth(calendardate) = Eomonth(Getdate())
        UNION ALL
        SELECT [calendarid],
               [Period] = CONVERT(VARCHAR, [calendardate]),
               [Type] = 'Last 30 days',
               [TypeDK] = 'Sidste 30 dage',
               [Sort] = 10
        FROM   [dim].[calendar]
        WHERE  Datediff(day, Getdate(), [calendardate]) BETWEEN -29 AND 0
               AND calendardate <= CONVERT(DATE, Getdate())
        UNION ALL
        SELECT [calendarid],
               [Period] = CONVERT(VARCHAR, [calendardate]),
               [Type] = 'Last month',
               [TypeDK] = 'Sidste Måned',
               [Sort] = 11
        FROM   [dim].[calendar]
        WHERE  Eomonth(calendardate) = Eomonth(Dateadd(month, -1, Getdate()))
        UNION ALL
        SELECT [calendarid],
               [Period] = CONVERT(VARCHAR, [calendardate]),
               [Type] = 'Last 6 weeks',
               [TypeDK] = 'Sidste 6 uger',
               [Sort] = 12
        FROM   [dim].[calendar]
        WHERE  Datediff(week, Getdate(), Dateadd(dd, -1, [calendardate]))
               BETWEEN -5
               AND
               0
               AND calendardate <= CONVERT(DATE, Getdate())
        UNION ALL
        SELECT [calendarid],
               [Period] = CONVERT(VARCHAR, [calendardate]),
               [Type] = 'Quarter to date',
               [TypeDK] = 'Kvartal til dato',
               [Sort] = 13
        FROM   [dim].[calendar]
        WHERE  convert(varchar,datename(year,calendarKey)) + convert(varchar,datename(quarter,calendarKey)) = 10 * Year(Getdate()) + Datepart(quarter, Getdate())
               AND calendardate <= CONVERT(DATE, Getdate())
        UNION ALL
        SELECT [calendarid],
               [Period] = CONVERT(VARCHAR, [calendardate]),
               [Type] = 'Current quarter',
               [TypeDK] = 'Dette kvartal',
               [Sort] = 14
        FROM   [dim].[calendar]
        WHERE  convert(varchar,datename(year,calendarKey)) + convert(varchar,datename(quarter,calendarKey)) = 10 * Year(Getdate()) + Datepart(quarter, Getdate())
        UNION ALL
        SELECT [calendarid],
               [Period] = CONVERT(VARCHAR, [calendardate]),
               [Type] = 'Last quarter',
               [TypeDK] = 'Sidste kvartal',
               [Sort] = 15
        FROM   [dim].[calendar]
        WHERE  [calendardate] BETWEEN Dateadd(qq, Datediff(qq, 0, Getdate()) - 1
                                      , 0)
                                      AND
                                             Dateadd(dd, -1,
                                             Dateadd(qq, Datediff(qq, 0, Getdate
                                                         ()), 0)
                                             )
               AND calendardate <= CONVERT(DATE, Getdate())
        UNION ALL
        SELECT [calendarid],
               [Period] = CONVERT(VARCHAR, [calendardate]),
               [Type] = 'Last 12 weeks',
               [TypeDK] = 'Sidste 12 uger',
               [Sort] = 16
        FROM   [dim].[calendar]
        WHERE  Datediff(week, Getdate(), Dateadd(dd, -1, [calendardate]))
               BETWEEN -11
               AND 0
               AND calendardate <= CONVERT(DATE, Getdate())
        UNION ALL
        SELECT [calendarid],
               [Period] = CONVERT(VARCHAR, [calendardate]),
               [Type] = 'Last 13 weeks',
               [TypeDK] = 'Sidste 13 uger',
               [Sort] = 17
        FROM   [dim].[calendar]
        WHERE  Datediff(week, Getdate(), Dateadd(dd, -1, [calendardate]))
               BETWEEN -13
               AND 0
               AND calendardate <= CONVERT(DATE, Getdate())
        UNION ALL
        SELECT [calendarid],
               [Period] = CONVERT(VARCHAR, [calendardate]),
               [Type] = 'Last 6 months',
               [TypeDK] = 'Sidste 6 Måneder',
               [Sort] = 18
        FROM   [dim].[calendar]
        WHERE  Datediff(month, Getdate(), Dateadd(dd, -1, [calendardate]))
               BETWEEN -5
               AND 0
               AND calendardate <= CONVERT(DATE, Getdate())
        UNION ALL
        SELECT [calendarid],
               [Period] = CONVERT(VARCHAR, [calendardate]),
               [Type] = 'Current halfyear',
               [TypeDK] = 'Dette halvår',
               [Sort] = 19
        FROM   [dim].[calendar]
        WHERE  [calendardate] BETWEEN CONVERT(DATE, Dateadd(quarter,
                                                    Datediff(
                                                    quarter,
                                                                     0
                                                                     ,
                                                                     Getdate())
                                                    /
                                                    2 * 2
                                                    ,
                                                    +0)) AND
                                             CONVERT(DATE, Dateadd(quarter,
                                                           Datediff(
                                                           quarter, 0
                                                                            ,
                                                           Getdate()
                                                           )
                                                           /
                                                           2 *
                                                                            2 +
                                                           2, -1))
        UNION ALL
        SELECT [calendarid],
               [Period] = CONVERT(VARCHAR, [calendardate]),
               [Type] = 'Last halfyear',
               [TypeDK] = 'Sidste halvår',
               [Sort] = 20
        FROM   [dim].[calendar]
        WHERE  [calendardate] BETWEEN CONVERT(DATE, Dateadd(year, -1,
                                                    Dateadd(quarter,
                                                           Datediff(quarter,
                                                           0,
                                                           CONVERT(DATE, Getdate
                                                           ())
                                                                      )
                                                                      / 2
                                                                             * 2
                                                           + 2,
                                                    -0
                                                    ))) AND
                                             CONVERT(DATE, Dateadd(year, -1,
                                                           Dateadd(quarter,
                                                           Datediff(
                                                           quarter, 0
                                                                            ,
                                                           CONVERT(
                                      DATE
                                      , Getdate())
                                      )
                                      / 2 * 2 + 4, -1)))
        UNION ALL
        SELECT [calendarid],
               [Period] = CONVERT(VARCHAR, [calendardate]),
               [Type] = 'Current year',
               [TypeDK] = 'I år',
               [Sort] = 21
        FROM   [dim].[calendar]
        WHERE  [year] = Year(Getdate())
        UNION ALL
        SELECT [calendarid],
               [Period] = CONVERT(VARCHAR, [calendardate]),
               [Type] = 'Year to date',
               [TypeDK] = 'År til dato',
               [Sort] = 22
        FROM   [dim].[calendar]
        WHERE  [year] = Year(Getdate())
               AND calendardate <= CONVERT(DATE, Getdate())
        UNION ALL
        SELECT [calendarid],
               [Period] = CONVERT(VARCHAR, [calendardate]),
               [Type] = 'Last year',
               [TypeDK] = 'Sidste år',
               [Sort] = 23
        FROM   [dim].[calendar]
        WHERE  [year] = Year(Getdate()) - 1
        UNION ALL
        SELECT [calendarid],
               [Period] = CONVERT(VARCHAR, [calendardate]),
               [Type] = 'Last 12 months',
               [TypeDK] = 'Sidste 12 Måneder',
               [Sort] = 24
        FROM   [dim].[calendar]
        WHERE  Datediff(month, Getdate(), Dateadd(dd, -1, [calendardate]))
               BETWEEN -11
               AND 0
               AND calendardate <= CONVERT(DATE, Getdate())
        UNION ALL
        SELECT [calendarid],
               [Period] = CONVERT(VARCHAR, [calendardate]),
               [Type] = 'Last 13 months',
               [TypeDK] = 'Sidste 13 Måneder',
               [Sort] = 25
        FROM   [dim].[calendar]
        WHERE  Datediff(month, Getdate(), Dateadd(dd, -1, [calendardate]))
               BETWEEN -12
               AND 0
               AND calendardate <= CONVERT(DATE, Getdate())
        UNION ALL
        SELECT [calendarid],
               [Period] = CONVERT(VARCHAR, [calendardate]),
               [Type] = 'Select period',
               [TypeDK] = 'Vælg periode',
               [Sort] = 26
        FROM   [dim].[calendar]
        UNION ALL
        SELECT [calendarid],
               [Period] = CONVERT(VARCHAR, [calendardate]),
               [Type] = 'Select date',
               [TypeDK] = 'Vælg dag',
               [Sort] = 27
        FROM   [dim].[calendar]
        /*WHERE DATEDIFF(DAY, GETDATE(), [CalendarDate]) between -29 and 0*/
        UNION ALL
        SELECT [calendarid],
               [Period] = LEFT(CONVERT(VARCHAR, convert(varchar,[WeekYear]) + right('0'+ convert(varchar,[WeekNumber]),2)), 4)
                          + [weekname],
               [Type] = 'Select week',
               [TypeDK] = 'Vælg uge',
               [Sort] = 28
        FROM   [dim].[calendar]
        /*WHERE DATEDIFF(YEAR, GETDATE(), DATEADD(dd, - 1, [CalendarDate])) between -2 and 0*/
        UNION ALL
        SELECT [calendarid],
               [Period] = CONVERT(VARCHAR, [year]) + 'M'
                          + RIGHT(CONVERT(VARCHAR, 100 + [monthnumber]), 2),
               [Type] = 'Select month',
               [TypeDK] = 'Vælg måned',
               [Sort] = 29
        FROM   [dim].[calendar]
        /*WHERE DATEDIFF(YEAR, GETDATE(), DATEADD(dd, - 1, [CalendarDate])) between -2 and 0*/
        UNION ALL
        SELECT [calendarid],
               [Period] = CONVERT(VARCHAR, [year]) + 'Q'
                          + CONVERT(VARCHAR, [quarternumber]),
               [Type] = 'Select quarter',
               [TypeDK] = 'Vælg kvartal',
               [Sort] = 30
        FROM   [dim].[calendar]
       /*WHERE DATEDIFF(YEAR, GETDATE(), DATEADD(dd, - 1, [CalendarDate])) between -2 and 0*/
        UNION ALL
        SELECT [calendarid],
               [Period] = CONVERT(VARCHAR, [year]),
               [Type] = 'Select year',
               [TypeDK] = 'Vælg år',
               [Sort] = 31
        FROM   [dim].[calendar]
       /*WHERE DATEDIFF(YEAR, GETDATE(), DATEADD(dd, - 1, [CalendarDate])) between -2 and 0 */) CP
       JOIN dimview.calendar C
         ON CP.calendarid = C.calendarid
WHERE  CP.calendarid >= 19000101
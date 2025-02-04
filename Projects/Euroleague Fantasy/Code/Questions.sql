-- All time best --

SELECT Player, COUNT(Player) 'Total Games', SUM(Valuation) as 'PIR', SUM(UpdatedValuation) as 'PIRB',  CAST(AVG(UpdatedValuation) AS DECIMAL(10, 2)) AS 'AvgPIRB', 
CAST(SUM(FreeThrowsMade) * 1.0 / NULLIF(SUM(FreeThrowsAttempted), 0) *100 AS DECIMAL(10, 2)) AS 'FreeThrowPercentage',
CAST(SUM(FieldGoalsMade2) * 1.0 / NULLIF(SUM(FieldGoalsAttempted2), 0) *100 AS DECIMAL(10, 2)) AS 'FG2Percentage',
CAST(SUM(FieldGoalsMade3) * 1.0 / NULLIF(SUM(FieldGoalsAttempted3), 0) *100 AS DECIMAL(10, 2)) AS 'FG3Percentage',
CAST(SUM(TotalRebounds) * 1.0 / NULLIF(COUNT(Player), 0) AS DECIMAL(10, 2)) AS 'ReboundsAverage',
CAST(SUM(Assistances) * 1.0 / NULLIF(COUNT(Player), 0) AS DECIMAL(10, 2)) AS 'AsistAverage',
CAST(SUM(Steals) * 1.0 / NULLIF(COUNT(Player), 0) AS DECIMAL(10, 2)) AS 'StealAverage',
CAST(SUM(FoulsReceived) * 1.0 / NULLIF(COUNT(Player), 0) AS DECIMAL(10, 2)) AS 'FoulsReceivedAverage',
CAST(SUM(CAST(IsStarter AS INT)) * 1.0 / NULLIF(COUNT(Player), 0) * 100 AS DECIMAL(10, 2)) AS 'StarterPercentage',
CAST(SUM(TotalSeconds) * 1.0 / NULLIF(COUNT(Player), 0) / 60 AS DECIMAL(10, 2)) AS 'MinutesAVG',
CAST(SUM(Plusminus) * 1.0 / NULLIF(COUNT(Player), 0) AS DECIMAL(10, 2)) AS 'PlusMinus'
FROM dbo.PlayersStats
GROUP BY Player
HAVING COUNT(Player) >= 30 AND CAST(AVG(UpdatedValuation) AS DECIMAL(10, 2)) >= 12
ORDER BY AVGPIRB DESC

-- per season --

SELECT Player, SeasonCode, COUNT(Player) 'Total Games', SUM(Valuation) as 'PIR', SUM(UpdatedValuation) as 'PIRB',  CAST(AVG(UpdatedValuation) AS DECIMAL(10, 2)) AS 'AvgPIRB', 
CAST(SUM(FreeThrowsMade) * 1.0 / NULLIF(SUM(FreeThrowsAttempted), 0) *100 AS DECIMAL(10, 2)) AS 'FreeThrowPercentage',
CAST(SUM(FieldGoalsMade2) * 1.0 / NULLIF(SUM(FieldGoalsAttempted2), 0) *100 AS DECIMAL(10, 2)) AS 'FG2Percentage',
CAST(SUM(FieldGoalsMade3) * 1.0 / NULLIF(SUM(FieldGoalsAttempted3), 0) *100 AS DECIMAL(10, 2)) AS 'FG3Percentage',
CAST(SUM(TotalRebounds) * 1.0 / NULLIF(COUNT(Player), 0) AS DECIMAL(10, 2)) AS 'ReboundsAverage',
CAST(SUM(Assistances) * 1.0 / NULLIF(COUNT(Player), 0) AS DECIMAL(10, 2)) AS 'AsistAverage',
CAST(SUM(Steals) * 1.0 / NULLIF(COUNT(Player), 0) AS DECIMAL(10, 2)) AS 'StealAverage',
CAST(SUM(FoulsReceived) * 1.0 / NULLIF(COUNT(Player), 0) AS DECIMAL(10, 2)) AS 'FoulsReceivedAverage',
CAST(SUM(CAST(IsStarter AS INT)) * 1.0 / NULLIF(COUNT(Player), 0) * 100 AS DECIMAL(10, 2)) AS 'StarterPercentage',
CAST(SUM(TotalSeconds) * 1.0 / NULLIF(COUNT(Player), 0) / 60 AS DECIMAL(10, 2)) AS 'MinutesAVG',
CAST(SUM(Plusminus) * 1.0 / NULLIF(COUNT(Player), 0) AS DECIMAL(10, 2)) AS 'PlusMinus'
FROM dbo.PlayersStats
GROUP BY Player, SeasonCode
HAVING CAST(AVG(UpdatedValuation) AS DECIMAL(10, 2)) >= 12
ORDER BY SeasonCode DESC, AVGPIRB DESC

-- Creates table of players with games >= 50 and Avg PIR >= 13 --

SELECT *
INTO dbo.PlayersWith50PlusGames
FROM dbo.PlayersTotalStats
WHERE TotalGames >= 50 AND AvgValuation >= 13;

DROP TABLE dbo.PlayersWith50PlusGames;

-- just check the top players
WITH Percentile AS (
    SELECT 
        Player,
        AvgValuation,
        PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY AvgValuation DESC) 
            OVER () AS PercentileValue
    FROM dbo.PlayersTotalStats
)
SELECT *
FROM Percentile
WHERE AvgValuation >= PercentileValue
ORDER BY AvgValuation DESC;


-- Add columns in table PlayersWith50PlusGames--

ALTER TABLE dbo.PlayersWith50PlusGames
ADD IsStarter INT;

ALTER TABLE dbo.PlayersWith50PlusGames
ADD IsPlaying INT;

ALTER TABLE dbo.PlayersWith50PlusGames
ADD Jersey INT;

ALTER TABLE dbo.PlayersWith50PlusGames
ADD FoulsReceived INT;

ALTER TABLE dbo.PlayersWith50PlusGames
ADD PlusMinus INT;

ALTER TABLE dbo.PlayersWith50PlusGames
ADD PeakHour time; -- best hour to play --

UPDATE dbo.PlayersWith50PlusGames
SET PeakHour = CONVERT(TIME(0), PeakHour);


-- Update IsStarter column --

UPDATE dbo.PlayersWith50PlusGames
SET dbo.PlayersWith50PlusGames.IsStarter = PS.IsStarterCount
FROM dbo.PlayersWith50PlusGames
INNER JOIN (
    SELECT 
        Player_ID,
        COUNT(CASE WHEN IsStarter = 1 THEN 1 END) AS IsStarterCount
    FROM dbo.PlayersStats
    GROUP BY Player_ID
) PS
ON dbo.PlayersWith50PlusGames.PlayerID = PS.Player_ID;

-- Update IsPlaying column --

UPDATE dbo.PlayersWith50PlusGames
SET dbo.PlayersWith50PlusGames.IsPlaying = PS.IsPlayingCount
FROM dbo.PlayersWith50PlusGames
INNER JOIN (
    SELECT 
        Player_ID,
        COUNT(CASE WHEN IsPlaying = 1 THEN 1 END) AS IsPlayingCount
    FROM dbo.PlayersStats
    GROUP BY Player_ID
) PS
ON dbo.PlayersWith50PlusGames.PlayerID = PS.Player_ID;

-- Update Jersey column --

UPDATE dbo.PlayersWith50PlusGames
SET dbo.PlayersWith50PlusGames.Jersey = PS.Jersey
FROM dbo.PlayersWith50PlusGames
INNER JOIN (
    SELECT Player_ID, Jersey
    FROM dbo.PlayersStats 
) PS
ON dbo.PlayersWith50PlusGames.PlayerID = PS.Player_ID;

-- Update FoulsReceived column --

UPDATE PW50
SET PW50.FoulsReceived = PS.TotalFoulsReceived
FROM dbo.PlayersWith50PlusGames PW50
INNER JOIN (
    SELECT 
        Player_ID,
        SUM(FoulsReceived) AS TotalFoulsReceived
    FROM dbo.PlayersStats
    GROUP BY Player_ID
) PS
ON PW50.PlayerID = PS.Player_ID;

-- Update PlusMinus column --

UPDATE PW50
SET PW50.PlusMinus = PS.TotalPlusminus
FROM dbo.PlayersWith50PlusGames PW50
INNER JOIN (
    SELECT 
        Player_ID,
        SUM(Plusminus) AS TotalPlusMinus
    FROM dbo.PlayersStats
    GROUP BY Player_ID
) PS
ON PW50.PlayerID = PS.Player_ID;

-- Update PeakHour column --
-- Βήμα 1: Υπολογισμός της Ώρας με τις Περισσότερες Επιδόσεις
WITH PlayerPeakHours AS (
    SELECT 
        PS.Player_ID,
        HS.Hour,
        COUNT(*) AS HighPerformanceCount,
        ROW_NUMBER() OVER (
            PARTITION BY PS.Player_ID 
            ORDER BY COUNT(*) DESC
        ) AS RowNum
    FROM dbo.PlayersStats PS
    INNER JOIN dbo.HeaderStats HS
        ON PS.GameCode = HS.GameCode
        AND PS.SeasonCode = HS.SeasonCode
    WHERE PS.Valuation >= 15
    GROUP BY PS.Player_ID, HS.Hour
)

-- Βήμα 2: Ενημέρωση του dbo.PlayersWith50PlusGames
UPDATE PW50
SET PW50.PeakHour = PPH.Hour
FROM dbo.PlayersWith50PlusGames PW50
INNER JOIN PlayerPeakHours PPH
    ON PW50.PlayerID = PPH.Player_ID
WHERE PPH.RowNum = 1;



-- Test if i done right --

SELECT PlayerId, Player, TotalGames, IsStarter
FROM dbo.PlayersWith50PlusGames
ORDER BY IsStarter DESC;

SELECT 
    Player_ID,
    COUNT(GameCode) AS TotalGames, -- Συνολικοί αγώνες για κάθε παίκτη
    COUNT(CASE WHEN IsStarter = 1 THEN 1 END) AS IsStarterCount -- Αγώνες όπου ήταν βασικός
FROM dbo.PlayersStats
GROUP BY Player_ID
ORDER BY Player_ID;

-- ***** ANALYSIS ***** --

-- Percentage starters/finishers
SELECT 
    Player,
    TotalGames,
    IsStarter,
    CAST(IsStarter * 100.0 / NULLIF(TotalGames, 0) AS DECIMAL(10, 2)) AS StarterPercentage,
	CAST(IsPlaying * 100.0 / NULLIF(TotalGames, 0) AS DECIMAL(10, 2)) AS FinishingPercentage,
	CAST((AvgSeconds / 60 ) AS DECIMAL(10,2)) AS 'Average Minutes',
	CAST(AvgValuation / (AvgSeconds/60)  AS DECIMAL(10,2)) AS FPM,
	AvgPoints,
	CAST( (( CAST(FieldGoalsAttempted2 AS DECIMAL(10,2))  + CAST(FieldGoalsAttempted3 AS DECIMAL(10,2))) / TotalGames) AS DECIMAL(10,2)) AS 'Attempted shots',
	FTPercentage AS '% FT',
	AvgRebounds AS 'AVG Rebounds',
	AvgAssistances AS 'AVG assist',
	AvgTurnovers AS 'AVG turnovers',
	CAST((CAST(FoulsReceived AS DECIMAL(10,2)) / CAST(TotalGames AS DECIMAL(10,2)) ) AS DECIMAL(10,2)) AS 'AVG Fouls Received',
	CAST((CAST(PlusMinus AS DECIMAL(10,2)) / CAST(TotalGames AS DECIMAL(10,2)) ) AS DECIMAL(10,2)) AS 'AVG Plus/Minus',
	LEFT(PeakHour,8),
	AvgValuation
FROM dbo.PlayersWith50PlusGames
ORDER BY StarterPercentage DESC;

-- Create TopPlayersPerSeason

CREATE TABLE dbo.TopPlayersPerSeason (
    Player_ID NVARCHAR(50),
    IsStarter INT,
    IsPlaying INT,
    Team NVARCHAR(50),
    Jersey TINYINT,
    Player NVARCHAR(50),
    TotalSeconds INT,
    AvgTotalSeconds DECIMAL(10, 2),
    TotalGames INT,
    TotalPoints INT,
    AvgTotalPoints DECIMAL(10, 2),
    FieldGoalsMade2 INT,
    FieldGoalsAttempted2 INT,
    FG2Percentage DECIMAL(10, 2),
    FieldGoalsMade3 INT,
    FieldGoalsAttempted3 INT,
    FG3Percentage DECIMAL(10, 2),
    FreeThrowsMade INT,
    FreeThrowsAttempted INT,
    FTPercentage DECIMAL(10, 2),
    TotalRebounds INT,
    AvgRebounds DECIMAL(10, 2),
    OffensiveRebounds INT,
    AvgOffensiveRebounds DECIMAL(10, 2),
    DefensiveRebounds INT,
    AvgDefensiveRebounds DECIMAL(10, 2),
    Assistances INT,
    AvgAssistances DECIMAL(10, 2),
    Steals INT,
    AvgSteals DECIMAL(10, 2),
    Turnovers INT,
    AvgTurnovers DECIMAL(10, 2),
    Valuation INT,
    AvgValuation DECIMAL(10, 2),
    PIRPercentage DECIMAL(10, 2),
    FoulsReceived INT,
    AvgFoulsReceived DECIMAL(10, 2),
    PlusMinus INT,
    AvgPlusMinus DECIMAL(10, 2),
    SeasonCode NVARCHAR(50)
);

-- Update table dbo.TopPlayersPerSeason


INSERT INTO dbo.TopPlayersPerSeason (
    Player_ID, IsStarter, IsPlaying, Team, Jersey, Player, 
    TotalSeconds, AvgTotalSeconds, TotalGames, 
    TotalPoints, AvgTotalPoints, 
    FieldGoalsMade2, FieldGoalsAttempted2, FG2Percentage, 
    FieldGoalsMade3, FieldGoalsAttempted3, FG3Percentage, 
    FreeThrowsMade, FreeThrowsAttempted, FTPercentage, 
    TotalRebounds, AvgRebounds, OffensiveRebounds, AvgOffensiveRebounds, 
    DefensiveRebounds, AvgDefensiveRebounds, 
    Assistances, AvgAssistances, Steals, AvgSteals, 
    Turnovers, AvgTurnovers, Valuation, AvgValuation, PIRPercentage, 
    FoulsReceived, AvgFoulsReceived, PlusMinus, AvgPlusMinus, 
    SeasonCode
)
SELECT 
    PS.Player_ID,
    SUM(CAST(PS.IsStarter AS INT)) AS IsStarter, -- Αριθμός αγώνων που ξεκίνησε βασικός
    SUM(CAST(PS.IsPlaying AS INT)) AS IsPlaying, -- Αριθμός αγώνων που συμμετείχε
    PS.Team,
    PS.Jersey,
    PS.Player,
    SUM(PS.TotalSeconds) AS TotalSeconds,
    CAST(SUM(PS.TotalSeconds) * 1.0 / COUNT(PS.GameCode) AS DECIMAL(10, 2)) AS AvgTotalSeconds,
    COUNT(PS.GameCode) AS TotalGames,
    SUM(PS.Points) AS TotalPoints,
    CAST(SUM(PS.Points) * 1.0 / COUNT(PS.GameCode) AS DECIMAL(10, 2)) AS AvgTotalPoints,
    SUM(PS.FieldGoalsMade2) AS FieldGoalsMade2,
    SUM(PS.FieldGoalsAttempted2) AS FieldGoalsAttempted2,
    CAST(SUM(PS.FieldGoalsMade2) * 1.0 / NULLIF(SUM(PS.FieldGoalsAttempted2), 0) * 100 AS DECIMAL(10, 2)) AS FG2Percentage,
    SUM(PS.FieldGoalsMade3) AS FieldGoalsMade3,
    SUM(PS.FieldGoalsAttempted3) AS FieldGoalsAttempted3,
    CAST(SUM(PS.FieldGoalsMade3) * 1.0 / NULLIF(SUM(PS.FieldGoalsAttempted3), 0) * 100 AS DECIMAL(10, 2)) AS FG3Percentage,
    SUM(PS.FreeThrowsMade) AS FreeThrowsMade,
    SUM(PS.FreeThrowsAttempted) AS FreeThrowsAttempted,
    CAST(SUM(PS.FreeThrowsMade) * 1.0 / NULLIF(SUM(PS.FreeThrowsAttempted), 0) * 100 AS DECIMAL(10, 2)) AS FTPercentage,
    SUM(PS.TotalRebounds) AS TotalRebounds,
    CAST(SUM(PS.TotalRebounds) * 1.0 / COUNT(PS.GameCode) AS DECIMAL(10, 2)) AS AvgRebounds,
    SUM(PS.OffensiveRebounds) AS OffensiveRebounds,
    CAST(SUM(PS.OffensiveRebounds) * 1.0 / COUNT(PS.GameCode) AS DECIMAL(10, 2)) AS AvgOffensiveRebounds,
    SUM(PS.DefensiveRebounds) AS DefensiveRebounds,
    CAST(SUM(PS.DefensiveRebounds) * 1.0 / COUNT(PS.GameCode) AS DECIMAL(10, 2)) AS AvgDefensiveRebounds,
    SUM(PS.Assistances) AS Assistances,
    CAST(SUM(PS.Assistances) * 1.0 / COUNT(PS.GameCode) AS DECIMAL(10, 2)) AS AvgAssistances,
    SUM(PS.Steals) AS Steals,
    CAST(SUM(PS.Steals) * 1.0 / COUNT(PS.GameCode) AS DECIMAL(10, 2)) AS AvgSteals,
    SUM(PS.Turnovers) AS Turnovers,
    CAST(SUM(PS.Turnovers) * 1.0 / COUNT(PS.GameCode) AS DECIMAL(10, 2)) AS AvgTurnovers,
    SUM(PS.Valuation) AS Valuation,
    CAST(SUM(PS.Valuation) * 1.0 / COUNT(PS.GameCode) AS DECIMAL(10, 2)) AS AvgValuation,
    CAST(SUM(PS.Valuation) * 1.0 / NULLIF(SUM(PS.Valuation), 0) * 100 AS DECIMAL(10, 2)) AS PIRPercentage,
    SUM(PS.FoulsReceived) AS FoulsReceived,
    CAST(SUM(PS.FoulsReceived) * 1.0 / COUNT(PS.GameCode) AS DECIMAL(10, 2)) AS AvgFoulsReceived,
    SUM(PS.Plusminus) AS PlusMinus,
    CAST(SUM(PS.Plusminus) * 1.0 / COUNT(PS.GameCode) AS DECIMAL(10, 2)) AS AvgPlusMinus,
    PS.SeasonCode
FROM dbo.PlayersStats AS PS
GROUP BY 
    PS.Player_ID, PS.Team, PS.Jersey, PS.Player, PS.SeasonCode
HAVING 
    CAST(SUM(PS.Valuation) * 1.0 / COUNT(PS.GameCode) AS DECIMAL(10, 2)) >= 13
ORDER BY 
    PS.SeasonCode, AvgValuation DESC;

-- Πινακας για τις ωρες αγωνων
CREATE TABLE dbo.AvgTeamValuationByTime (
    TimeRange NVARCHAR(20),
    AvgTeamValuationA DECIMAL(10, 2),
    AvgTeamValuationB DECIMAL(10, 2),
    OverallAvgValuation DECIMAL(10, 2)
);

-- Update dbo.AvgTeamValuationByTime
INSERT INTO dbo.AvgTeamValuationByTime (TimeRange, AvgTeamValuationA, AvgTeamValuationB, OverallAvgValuation)
SELECT 
    CONCAT(FORMAT(DATEADD(MINUTE, DATEDIFF(MINUTE, 0, Hour) / 30 * 30, 0), 'HH:mm'), ' - ', 
           FORMAT(DATEADD(MINUTE, (DATEDIFF(MINUTE, 0, Hour) / 30 + 1) * 30, 0), 'HH:mm')) AS TimeRange,
    CAST(AVG(CAST(TeamValuationA AS DECIMAL(10, 2))) AS DECIMAL(10, 2)) AS AvgTeamValuationA,
    CAST(AVG(CAST(TeamValuationB AS DECIMAL(10, 2))) AS DECIMAL(10, 2)) AS AvgTeamValuationB,
    CAST(AVG((CAST(TeamValuationA AS DECIMAL(10, 2)) + CAST(TeamValuationB AS DECIMAL(10, 2))) / 2) AS DECIMAL(10, 2)) AS OverallAvgValuation
FROM 
    dbo.HeaderStats
WHERE 
    Hour IS NOT NULL -- Φιλτράρει κενές τιμές
GROUP BY 
    CONCAT(FORMAT(DATEADD(MINUTE, DATEDIFF(MINUTE, 0, Hour) / 30 * 30, 0), 'HH:mm'), ' - ', 
           FORMAT(DATEADD(MINUTE, (DATEDIFF(MINUTE, 0, Hour) / 30 + 1) * 30, 0), 'HH:mm'))
ORDER BY 
    TimeRange;

-- Γηπεδα --

CREATE TABLE dbo.AvgTeamValuationByStadium (
    Stadium NVARCHAR(100),
    TotalGames INT,
    AvgTeamValuationA DECIMAL(10, 2),
    AvgTeamValuationB DECIMAL(10, 2),
    OverallAvgValuation DECIMAL(10, 2)
);


INSERT INTO dbo.AvgTeamValuationByStadium (Stadium, TotalGames, AvgTeamValuationA, AvgTeamValuationB, OverallAvgValuation)
SELECT 
    Stadium,
    COUNT(GameCode) AS TotalGames,
    CAST(AVG(CAST(TeamValuationA AS DECIMAL(10, 2))) AS DECIMAL(10, 2)) AS AvgTeamValuationA,
    CAST(AVG(CAST(TeamValuationB AS DECIMAL(10, 2))) AS DECIMAL(10, 2)) AS AvgTeamValuationB,
    CAST(AVG((CAST(TeamValuationA AS DECIMAL(10, 2)) + CAST(TeamValuationB AS DECIMAL(10, 2))) / 2) AS DECIMAL(10, 2)) AS OverallAvgValuation
FROM 
    dbo.HeaderStats
WHERE 
    Stadium IS NOT NULL -- Αποκλείει κενές τιμές
GROUP BY 
    Stadium
ORDER BY 
    TotalGames DESC;

-- Θεατες --
CREATE TABLE dbo.AvgTeamValuationByAttendance (
    AttendanceRange NVARCHAR(20),
    TotalGames INT,
    AvgTeamValuationA DECIMAL(10, 2),
    AvgTeamValuationB DECIMAL(10, 2),
    OverallAvgValuation DECIMAL(10, 2)
);

INSERT INTO dbo.AvgTeamValuationByAttendance (AttendanceRange, TotalGames, AvgTeamValuationA, AvgTeamValuationB, OverallAvgValuation)
SELECT 
    CONCAT(CAST(FLOOR(CAST(Capacity AS INT) / 4000) * 4000 AS NVARCHAR), '-', CAST((FLOOR(CAST(Capacity AS INT) / 4000) + 1) * 4000 - 1 AS NVARCHAR)) AS AttendanceRange,
    COUNT(GameCode) AS TotalGames,
    CAST(AVG(CAST(TeamValuationA AS DECIMAL(10, 2))) AS DECIMAL(10, 2)) AS AvgTeamValuationA,
    CAST(AVG(CAST(TeamValuationB AS DECIMAL(10, 2))) AS DECIMAL(10, 2)) AS AvgTeamValuationB,
    CAST(AVG((CAST(TeamValuationA AS DECIMAL(10, 2)) + CAST(TeamValuationB AS DECIMAL(10, 2))) / 2) AS DECIMAL(10, 2)) AS OverallAvgValuation
FROM 
    dbo.HeaderStats
WHERE 
    Capacity IS NOT NULL AND Capacity != '' -- Αποκλείει κενές ή μη έγκυρες τιμές
GROUP BY 
    FLOOR(CAST(Capacity AS INT) / 4000)
ORDER BY 
    AttendanceRange;

--- Referee ---

CREATE TABLE dbo.AvgTeamValuationByReferee (
    Referee NVARCHAR(50),
    TotalGames INT,
    AvgTeamValuationA DECIMAL(10, 2),
    AvgTeamValuationB DECIMAL(10, 2),
    OverallAvgValuation DECIMAL(10, 2)
);

INSERT INTO dbo.AvgTeamValuationByReferee (Referee, TotalGames, AvgTeamValuationA, AvgTeamValuationB, OverallAvgValuation)
SELECT 
    Referee,
    COUNT(GameCode) AS TotalGames,
    CAST(AVG(CAST(TeamValuationA AS DECIMAL(10, 2))) AS DECIMAL(10, 2)) AS AvgTeamValuationA,
    CAST(AVG(CAST(TeamValuationB AS DECIMAL(10, 2))) AS DECIMAL(10, 2)) AS AvgTeamValuationB,
    CAST(AVG((CAST(TeamValuationA AS DECIMAL(10, 2)) + CAST(TeamValuationB AS DECIMAL(10, 2))) / 2) AS DECIMAL(10, 2)) AS OverallAvgValuation
FROM (
    SELECT Referee1 AS Referee, GameCode, SeasonCode, TeamValuationA, TeamValuationB FROM dbo.HeaderStats
    UNION ALL
    SELECT Referee2 AS Referee, GameCode, SeasonCode, TeamValuationA, TeamValuationB FROM dbo.HeaderStats
    UNION ALL
    SELECT Referee3 AS Referee, GameCode, SeasonCode, TeamValuationA, TeamValuationB FROM dbo.HeaderStats
) Referees
WHERE Referee IS NOT NULL AND Referee != '' -- Αποκλείει κενές ή μη έγκυρες τιμές
GROUP BY Referee
ORDER BY Referee;


-- Προπονητες --

CREATE TABLE dbo.AvgTeamValuationByCoach (
    Coach NVARCHAR(50),
    TotalGames INT,
    AvgTeamValuationA DECIMAL(10, 2),
    AvgTeamValuationB DECIMAL(10, 2),
    OverallAvgValuation DECIMAL(10, 2)
);

INSERT INTO dbo.AvgTeamValuationByCoach (Coach, TotalGames, AvgTeamValuationA, AvgTeamValuationB, OverallAvgValuation)
SELECT 
    Coach,
    COUNT(GameCode) AS TotalGames,
    CAST(AVG(CAST(TeamValuationA AS DECIMAL(10, 2))) AS DECIMAL(10, 2)) AS AvgTeamValuationA,
    CAST(AVG(CAST(TeamValuationB AS DECIMAL(10, 2))) AS DECIMAL(10, 2)) AS AvgTeamValuationB,
    CAST(AVG((CAST(TeamValuationA AS DECIMAL(10, 2)) + CAST(TeamValuationB AS DECIMAL(10, 2))) / 2) AS DECIMAL(10, 2)) AS OverallAvgValuation
FROM (
    SELECT CoachA AS Coach, GameCode, SeasonCode, TeamValuationA, TeamValuationB FROM dbo.HeaderStats
    UNION ALL
    SELECT CoachB AS Coach, GameCode, SeasonCode, TeamValuationA, TeamValuationB FROM dbo.HeaderStats
) Coaches
WHERE Coach IS NOT NULL AND Coach != '' -- Αποκλείει κενές ή μη έγκυρες τιμές
GROUP BY Coach
ORDER BY Coach;

--- Ομαδικοι ποντοι ---
CREATE TABLE dbo.AvgValuationByScoreRange (
    ScoreRange NVARCHAR(20),
    TotalGames INT,
    AvgTeamValuationA DECIMAL(10, 2),
    AvgTeamValuationB DECIMAL(10, 2),
    OverallAvgValuation DECIMAL(10, 2)
);

INSERT INTO dbo.AvgValuationByScoreRange (ScoreRange, TotalGames, AvgTeamValuationA, AvgTeamValuationB, OverallAvgValuation)
SELECT 
    CONCAT(FLOOR(Score / 5) * 5, '-', FLOOR(Score / 5) * 5 + 4) AS ScoreRange,
    COUNT(*) AS TotalGames,
    CAST(AVG(CAST(TeamValuationA AS DECIMAL(10, 2))) AS DECIMAL(10, 2)) AS AvgTeamValuationA,
    CAST(AVG(CAST(TeamValuationB AS DECIMAL(10, 2))) AS DECIMAL(10, 2)) AS AvgTeamValuationB,
    CAST(AVG((CAST(TeamValuationA AS DECIMAL(10, 2)) + CAST(TeamValuationB AS DECIMAL(10, 2))) / 2) AS DECIMAL(10, 2)) AS OverallAvgValuation
FROM (
    SELECT ScoreA AS Score, TeamValuationA, TeamValuationB FROM dbo.HeaderStats
    UNION ALL
    SELECT ScoreB AS Score, TeamValuationA, TeamValuationB FROM dbo.HeaderStats
) Scores
WHERE Score IS NOT NULL
GROUP BY FLOOR(Score / 5)
ORDER BY ScoreRange;

-- Ανιχνευση πατερνων στα σκορ --

CREATE TABLE dbo.PlayerStreaks (
    Player_ID NVARCHAR(50),
    SeasonCode NVARCHAR(50),
    StreakLength INT,
    AvgValuation DECIMAL(10, 2)
);

WITH RankedStats AS (
    SELECT 
        Player_ID,
        SeasonCode,
        GameCode,
        Valuation,
        CASE 
            WHEN Valuation >= 13 THEN 1
            ELSE 0
        END AS IsAbove13,
        ROW_NUMBER() OVER (PARTITION BY Player_ID, SeasonCode ORDER BY GameCode) 
            - SUM(CASE WHEN Valuation >= 13 THEN 1 ELSE 0 END) OVER (PARTITION BY Player_ID, SeasonCode ORDER BY GameCode) 
            AS StreakGroup
    FROM dbo.PlayersStats
),
Streaks AS (
    SELECT 
        Player_ID,
        SeasonCode,
        StreakGroup,
        COUNT(*) AS StreakLength,
        AVG(CAST(Valuation AS DECIMAL(10, 2))) AS AvgValuation
    FROM RankedStats
    WHERE IsAbove13 = 1
    GROUP BY Player_ID, SeasonCode, StreakGroup
)
INSERT INTO dbo.PlayerStreaks (Player_ID, SeasonCode, StreakLength, AvgValuation)
SELECT 
    Player_ID,
    SeasonCode,
    StreakLength,
    AvgValuation
FROM Streaks
WHERE StreakLength >= 2;

-- Διαολοεβδομαδες--

CREATE TABLE dbo.PlayerPerformanceInBackToBackGames (
    Player_ID NVARCHAR(50),
    SeasonCode NVARCHAR(50),
    GameCode SMALLINT,
    Valuation DECIMAL(10, 2),
    AvgValuation DECIMAL(10, 2),
    PerformanceCategory NVARCHAR(20)
);

SELECT 
    GameCode,
    SeasonCode,
    Date,
    TeamA,
    TeamB,
    CASE 
        WHEN DATEDIFF(DAY, Date, NextGameDateTeamA) BETWEEN 2 AND 3 THEN 'TeamA'
        WHEN DATEDIFF(DAY, Date, NextGameDateTeamB) BETWEEN 2 AND 3 THEN 'TeamB'
    END AS BackToBackTeam
INTO #BackToBackGames
FROM (
    SELECT 
        GameCode,
        SeasonCode,
        Date,
        TeamA,
        TeamB,
        LEAD(Date) OVER (PARTITION BY TeamA, SeasonCode ORDER BY Date) AS NextGameDateTeamA,
        LEAD(Date) OVER (PARTITION BY TeamB, SeasonCode ORDER BY Date) AS NextGameDateTeamB
    FROM dbo.HeaderStats
) GamesWithDateDiff
WHERE 
    DATEDIFF(DAY, Date, NextGameDateTeamA) BETWEEN 2 AND 3
    OR DATEDIFF(DAY, Date, NextGameDateTeamB) BETWEEN 2 AND 3;

WITH PlayerBackToBackPerformance AS (
    SELECT 
        p.Player_ID,
        p.SeasonCode,
        p.GameCode,
        p.Valuation,
        t.AvgValuation,
        CASE 
            WHEN p.Valuation >= t.AvgValuation THEN 'Above Avg'
            ELSE 'Below Avg'
        END AS PerformanceCategory
    FROM dbo.PlayersStats p
    INNER JOIN dbo.TopPlayersPerSeason t
        ON p.Player_ID = t.Player_ID 
        AND p.SeasonCode = t.SeasonCode
    INNER JOIN #BackToBackGames b
        ON p.GameCode = b.GameCode 
        AND p.SeasonCode = b.SeasonCode
)
INSERT INTO dbo.PlayerPerformanceInBackToBackGames (Player_ID, SeasonCode, GameCode, Valuation, AvgValuation, PerformanceCategory)
SELECT 
    Player_ID,
    SeasonCode,
    GameCode,
    Valuation,
    AvgValuation,
    PerformanceCategory
FROM PlayerBackToBackPerformance;

-- convert secs to minutes with new column --
-- Προσθήκη της στήλης TotalMinutes σε κάθε table
ALTER TABLE dbo.PlayersWith50PlusGames ADD TotalMinutes NVARCHAR(10);
ALTER TABLE dbo.TeamTotals ADD TotalMinutes NVARCHAR(10);
ALTER TABLE dbo.TopPlayersPerSeason ADD TotalMinutes NVARCHAR(10);

-- Υπολογισμός TotalMinutes για dbo.PlayersWith50PlusGames
UPDATE dbo.PlayersWith50PlusGames
SET TotalMinutes = FORMAT(TotalSeconds / 60, '00') + ':' + FORMAT(TotalSeconds % 60, '00');

-- Υπολογισμός TotalMinutes για dbo.TeamTotals
UPDATE dbo.TeamTotals
SET TotalMinutes = FORMAT(TotalSeconds / 60, '00') + ':' + FORMAT(TotalSeconds % 60, '00');

-- Υπολογισμός TotalMinutes για dbo.TopPlayersPerSeason
UPDATE dbo.TopPlayersPerSeason
SET TotalMinutes = FORMAT(TotalSeconds / 60, '00') + ':' + FORMAT(TotalSeconds % 60, '00');


-- Προσθήκη των στηλών TotalMinutes και AvgMinutes σε κάθε table
ALTER TABLE dbo.PlayersWith50PlusGames ADD AvgMinutes NVARCHAR(10);
ALTER TABLE dbo.TeamTotals ADD AvgMinutes NVARCHAR(10);
ALTER TABLE dbo.TopPlayersPerSeason ADD AvgMinutes NVARCHAR(10);

-- Υπολογισμός TotalMinutes και AvgMinutes για dbo.PlayersWith50PlusGames
UPDATE dbo.PlayersWith50PlusGames
SET 
    TotalMinutes = FORMAT(TotalSeconds / 60, '00') + ':' + FORMAT(TotalSeconds % 60, '00'),
    AvgMinutes = FORMAT((TotalSeconds / NULLIF(TotalGames, 0)) / 60, '00') + ':' + FORMAT((TotalSeconds / NULLIF(TotalGames, 0)) % 60, '00');


-- Υπολογισμός TotalMinutes και AvgMinutes για dbo.TopPlayersPerSeason
UPDATE dbo.TopPlayersPerSeason
SET 
    TotalMinutes = FORMAT(TotalSeconds / 60, '00') + ':' + FORMAT(TotalSeconds % 60, '00'),
    AvgMinutes = FORMAT((TotalSeconds / NULLIF(TotalGames, 0)) / 60, '00') + ':' + FORMAT((TotalSeconds / NULLIF(TotalGames, 0)) % 60, '00');

-- data cleaning and improve AvgTeamValuationReferee--
DELETE FROM dbo.AvgTeamValuationByReferee
WHERE Referee = '21';

DELETE FROM dbo.AvgTeamValuationByReferee
WHERE Referee = 'N/D';

ALTER TABLE dbo.AvgTeamValuationByReferee
ADD 
    TotalFoulsA INT,
    TotalFoulsB INT,
    AvgFoulsA DECIMAL(10, 2),
    AvgFoulsB DECIMAL(10, 2),
    TotalAvgFouls DECIMAL(10, 2);

WITH FoulsSummary AS (
    SELECT 
        R.Referee,
        SUM(CASE WHEN R.Referee = H.Referee1 OR R.Referee = H.Referee2 OR R.Referee = H.Referee3 THEN H.FoultsA ELSE 0 END) AS TotalFoulsA,
        SUM(CASE WHEN R.Referee = H.Referee1 OR R.Referee = H.Referee2 OR R.Referee = H.Referee3 THEN H.FoultsB ELSE 0 END) AS TotalFoulsB,
        COUNT(DISTINCT H.GameCode) AS TotalGames
    FROM dbo.AvgTeamValuationByReferee R
    LEFT JOIN dbo.HeaderStats H
        ON R.Referee = H.Referee1
        OR R.Referee = H.Referee2
        OR R.Referee = H.Referee3
    GROUP BY R.Referee
)
UPDATE R
SET 
    R.TotalFoulsA = FS.TotalFoulsA,
    R.TotalFoulsB = FS.TotalFoulsB,
    R.AvgFoulsA = CAST(FS.TotalFoulsA * 1.0 / NULLIF(FS.TotalGames, 0) AS DECIMAL(10, 2)),
    R.AvgFoulsB = CAST(FS.TotalFoulsB * 1.0 / NULLIF(FS.TotalGames, 0) AS DECIMAL(10, 2)),
    R.TotalAvgFouls = CAST(
        (FS.TotalFoulsA * 1.0 / NULLIF(FS.TotalGames, 0)) +
        (FS.TotalFoulsB * 1.0 / NULLIF(FS.TotalGames, 0))
        AS DECIMAL(10, 2))
FROM dbo.AvgTeamValuationByReferee R
INNER JOIN FoulsSummary FS
    ON R.Referee = FS.Referee;

-- data cleaning and improve AvgTeamValuationByCoach --

-- Δημιουργία προσωρινού πίνακα για τα νέα δεδομένα
SELECT 
    'ALIMPIJEVIC DUSAN' AS Coach,
    SUM(TotalGames) AS TotalGames,
    CAST(SUM(AvgTeamValuationA * TotalGames) * 1.0 / SUM(TotalGames) AS DECIMAL(10, 2)) AS AvgTeamValuationA,
    CAST(SUM(AvgTeamValuationB * TotalGames) * 1.0 / SUM(TotalGames) AS DECIMAL(10, 2)) AS AvgTeamValuationB,
    CAST(SUM(OverallAvgValuation * TotalGames) * 1.0 / SUM(TotalGames) AS DECIMAL(10, 2)) AS OverallAvgValuation
INTO #TempCorrectedCoaches
FROM dbo.AvgTeamValuationByCoach
WHERE Coach LIKE 'ALIMPΙJEVIC%';

-- Διαγραφή παλιών δεδομένων
DELETE FROM dbo.AvgTeamValuationByCoach
WHERE Coach LIKE 'ALIMPIJEVIC%';

-- Εισαγωγή των διορθωμένων δεδομένων
INSERT INTO dbo.AvgTeamValuationByCoach (Coach, TotalGames, AvgTeamValuationA, AvgTeamValuationB, OverallAvgValuation)
SELECT * FROM #TempCorrectedCoaches;

-- Διαγραφή του προσωρινού πίνακα
DROP TABLE #TempCorrectedCoaches;

-- διορθωση σφαλματων --

-- Ενημέρωση του IsStarter και IsPlaying στο dbo.TopPlayersPerSeason
ALTER TABLE dbo.TopPlayersPerSeason
DROP COLUMN IsStarter,
	 COLUMN IsPlaying;

ALTER TABLE dbo.TopPlayersPerSeason
ADD IsStarter INT,
    IsPlaying INT;


UPDATE TPS
SET TPS.IsStarter = PS.TotalStarters,
    TPS.IsPlaying = PS.TotalPlaying
FROM dbo.TopPlayersPerSeason TPS
JOIN (
    SELECT 
        Player_ID,
        SeasonCode,
        SUM(CASE WHEN IsStarter = 1 THEN 1 ELSE 0 END) AS TotalStarters,
        SUM(CASE WHEN IsPlaying = 1 THEN 1 ELSE 0 END) AS TotalPlaying
    FROM dbo.PlayersStats
    GROUP BY Player_ID, SeasonCode
) AS PS
ON TPS.Player_ID = PS.Player_ID AND TPS.SeasonCode = PS.SeasonCode;














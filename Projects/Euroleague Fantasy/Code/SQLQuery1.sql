ALTER TABLE dbo.PlayersStats
ADD UpdatedValuation FLOAT;

UPDATE dbo.PlayersStats
SET UpdatedValuation = 
  CASE 
    WHEN (PS.Team = HS.TeamA AND HS.ScoreA > HS.ScoreB) OR
         (PS.Team = HS.TeamB AND HS.ScoreB > HS.ScoreA)
    THEN Valuation * 1.10 -- Δίνουμε το bonus 10%
    ELSE Valuation        -- Διατηρούμε την αρχική τιμή
  END
FROM dbo.PlayersStats AS PS
JOIN dbo.HeaderStats AS HS
  ON PS.GameCode = HS.GameCode
  AND PS.SeasonCode = HS.SeasonCode;

-- Διορθωση 10% bonus στα αρνητικα PIR

UPDATE dbo.PlayersStats
SET UpdatedValuation = 
  CASE 
    WHEN (PS.Team = HS.TeamA AND HS.ScoreA > HS.ScoreB) OR
         (PS.Team = HS.TeamB AND HS.ScoreB > HS.ScoreA)
    THEN 
      CASE 
        WHEN Valuation < 0 THEN Valuation + ABS(Valuation) * 0.10
        ELSE Valuation * 1.10
      END
    ELSE Valuation
  END
FROM dbo.PlayersStats AS PS
JOIN dbo.HeaderStats AS HS
  ON PS.GameCode = HS.GameCode
  AND PS.SeasonCode = HS.SeasonCode;



-- Δημιουργία του νέου πίνακα
CREATE TABLE PlayersTotalStats (
    PlayerId NVARCHAR(50),
    Player NVARCHAR(50),
    Team NVARCHAR(50),
    TotalGames INT,
    TotalSeconds INT,
    AvgSeconds DECIMAL(10, 2),
    TotalPoints INT,
    AvgPoints DECIMAL(10, 2),
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
    FoulsCommited INT,
    AvgFoulsCommited DECIMAL(10, 2),
    FoulsReceived INT,
    AvgFoulsReceived DECIMAL(10, 2),
    Valuation INT,
    AvgValuation DECIMAL(10, 2),
    UpdatedValuation INT,
    AvgUpdatedValuation DECIMAL(10, 2),
    PIRPercentage DECIMAL(10, 2)
);

ALTER TABLE dbo.HeaderStats
ADD TeamValuationA INT NULL, -- Για την TeamA
    TeamValuationB INT NULL; -- Για την TeamB

-- Υπολογισμός για την TeamA
UPDATE dbo.HeaderStats
SET TeamValuationA = (
    SELECT SUM(PS.Valuation)
    FROM dbo.PlayersStats AS PS
    WHERE PS.GameCode = dbo.HeaderStats.GameCode
      AND PS.SeasonCode = dbo.HeaderStats.SeasonCode
      AND PS.Team = dbo.HeaderStats.TeamA
);

-- Υπολογισμός για την TeamB
UPDATE dbo.HeaderStats
SET TeamValuationB = (
    SELECT SUM(PS.Valuation)
    FROM dbo.PlayersStats AS PS
    WHERE PS.GameCode = dbo.HeaderStats.GameCode
      AND PS.SeasonCode = dbo.HeaderStats.SeasonCode
      AND PS.Team = dbo.HeaderStats.TeamB
);


UPDATE dbo.PlayersTotalStats
SET TotalGames = 0;

UPDATE PTS
SET PTS.TotalGames = PS.TotalGames
FROM dbo.PlayersTotalStats PTS
INNER JOIN (
    SELECT 
        Player_ID,
        COUNT(GameCode) AS TotalGames
    FROM dbo.PlayersStats
    GROUP BY Player_ID
) PS
ON PTS.PlayerId = PS.Player_ID;

SELECT 
    PTS.PlayerID, 
    PTS.Player, 
    PTS.TotalGames,
    PS.TotalGames AS TotalGamesInStats
FROM dbo.PlayersTotalStats PTS
INNER JOIN (
    SELECT 
        Player_ID,
        COUNT(GameCode) AS TotalGames
    FROM dbo.PlayersStats
    GROUP BY Player_ID
) PS
ON PTS.PlayerID = PS.Player_ID
ORDER BY PTS.TotalGames DESC;

SELECT 
    PTS.PlayerID,
    PTS.Player,
    PTS.TotalPoints,
    SUM(PS.Points) AS TotalPointsInStats
FROM dbo.PlayersTotalStats PTS
INNER JOIN dbo.PlayersStats PS
ON PTS.PlayerID = PS.Player_ID
GROUP BY PTS.PlayerID, PTS.Player, PTS.TotalPoints
ORDER BY TotalPoints DESC;

-- Εισαγωγή δεδομένων στον πίνακα
SELECT 
    PS.Player_ID,
    PS.Player,
    COUNT(DISTINCT PS.GameCode) AS TotalGames,
    SUM(PS.Points) AS TotalPoints,
    AVG(PS.Points) AS AvgPoints
FROM dbo.PlayersStats AS PS
GROUP BY PS.Player_ID, PS.Player;

SELECT DISTINCT Team
FROM dbo.PlayersStats
ORDER BY 1

UPDATE dbo.PlayersStats
SET Team = 'PARTIZAN'
WHERE Team LIKE '%PARTIZAN%'
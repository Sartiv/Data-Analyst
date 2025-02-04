SELECT DISTINCT name_Team
FROM dbo.TeamTotals
ORDER BY 1

UPDATE dbo.PlayersStats
SET name_Team = 'BASKONIA'
WHERE name_Team LIKE '%BASKONIA%'
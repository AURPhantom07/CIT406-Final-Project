-- ============================================
-- QUERY_PORTFOLIO.SQL
-- Athletics Management System
-- CIT 406 - Term Project Query Portfolio
-- ============================================

-- ============================================
-- QUERY 1
-- Question: Which student-athletes play on teams that have won at
--           least 10 games? Show each student's name and team name.
-- SQL Features: INNER JOIN, non-correlated subquery in WHERE
-- ============================================
SELECT s.First_Name, s.Last_Name, t.Name AS Team_Name
FROM STUDENTS s
JOIN TEAMS t ON s.Team_ID = t.Team_ID
WHERE s.Team_ID IN (
    SELECT Team_ID
    FROM TEAMS
    WHERE Win_Count >= 10
)
ORDER BY t.Name, s.Last_Name;

-- ============================================
-- QUERY 2
-- Question: Which university teams have a winning record
--           (more wins than losses)?
-- SQL Features: WHERE with self-comparison, non-correlated subquery
--               in WHERE (used to identify university teams only)
-- ============================================
SELECT t.Name, t.Win_Count, t.Loss_Count
FROM TEAMS t
WHERE t.Win_Count > t.Loss_Count
  AND t.Team_ID IN (
      SELECT DISTINCT Team_ID
      FROM STUDENTS
      WHERE Team_ID IS NOT NULL
  )
ORDER BY t.Win_Count DESC;

-- ============================================
-- QUERY 3
-- Question: For each sport, how many students are currently enrolled
--           across all its teams, and how does that compare to the
--           sport's maximum roster size?
-- SQL Features: Multi-table JOIN, GROUP BY, COUNT, computed column,
--               ORDER BY
-- ============================================
SELECT sp.Name AS Sport,
       sp.Max_Roster_Size,
       COUNT(st.Student_ID) AS Enrolled_Count,
       sp.Max_Roster_Size - COUNT(st.Student_ID) AS Spots_Remaining
FROM SPORTS sp
JOIN TEAMS t     ON sp.Sport_ID = t.Sport_ID
LEFT JOIN STUDENTS st ON t.Team_ID = st.Team_ID
GROUP BY sp.Sport_ID, sp.Name, sp.Max_Roster_Size
ORDER BY Spots_Remaining ASC;

-- ============================================
-- QUERY 4
-- Question: For each location, how many games has it hosted?
-- SQL Features: LEFT JOIN, GROUP BY, COUNT, ORDER BY
-- ============================================
SELECT l.Name AS Location,
       COUNT(g.Game_ID) AS Games_Hosted
FROM LOCATIONS l
LEFT JOIN GAMES g ON l.Location_ID = g.Location_ID
GROUP BY l.Location_ID, l.Name
ORDER BY Games_Hosted DESC;

-- ============================================
-- QUERY 5
-- Question: Which coaches have not been assigned to run any practice?
-- SQL Features: LEFT JOIN, IS NULL
-- ============================================
SELECT c.First_Name, c.Last_Name
FROM COACHES c
LEFT JOIN PRACTICE_COACHES pc ON c.Coach_ID = pc.Coach_ID
WHERE pc.Coach_ID IS NULL
ORDER BY c.Last_Name;

-- ============================================
-- QUERY 6
-- Question: For each team, how many practices has it scheduled?
--           Include teams with zero practices in the result.
-- SQL Features: Correlated subquery in SELECT clause
-- ============================================
SELECT t.Name,
       (SELECT COUNT(*)
        FROM PRACTICES p
        WHERE p.Team_ID = t.Team_ID) AS Practice_Count
FROM TEAMS t
ORDER BY Practice_Count DESC, t.Name;

-- ============================================
-- QUERY 7
-- Question: Which team has the highest total attendance across its
--           home games? Show the team name and its total attendance.
-- SQL Features: Multi-join, GROUP BY, SUM, HAVING, nested subquery
--               (subquery inside HAVING, with another subquery in its
--               FROM clause)
-- ============================================
SELECT t.Name, SUM(g.Attendance) AS Total_Attendance
FROM TEAMS t
JOIN GAME_TEAMS gt ON t.Team_ID = gt.Team_ID
JOIN GAMES g ON gt.Game_ID = g.Game_ID
WHERE gt.HomeOrAway = 'Home'
GROUP BY t.Team_ID, t.Name
HAVING SUM(g.Attendance) = (
    SELECT MAX(total_att)
    FROM (
        SELECT SUM(g2.Attendance) AS total_att
        FROM GAMES g2
        JOIN GAME_TEAMS gt2 ON g2.Game_ID = gt2.Game_ID
        WHERE gt2.HomeOrAway = 'Home'
        GROUP BY gt2.Team_ID
    ) sub
);

-- ============================================
-- QUERY 8
-- Question: Which locations have hosted both a game and a practice?
-- SQL Features: INTERSECT
-- ============================================
SELECT l.Name AS Location
FROM LOCATIONS l
JOIN GAMES g ON l.Location_ID = g.Location_ID
INTERSECT
SELECT l.Name AS Location
FROM LOCATIONS l
JOIN PRACTICES p ON l.Location_ID = p.Location_ID;

-- ============================================
-- QUERY 9
-- Question: Rank teams within each sport by number of wins.
-- SQL Features: Window function (RANK), PARTITION BY, ORDER BY,
--               multi-table JOIN
-- ============================================
SELECT sp.Name AS Sport,
       t.Name AS Team,
       t.Win_Count,
       RANK() OVER (PARTITION BY sp.Sport_ID ORDER BY t.Win_Count DESC) AS Win_Rank
FROM TEAMS t
JOIN SPORTS sp ON t.Sport_ID = sp.Sport_ID
ORDER BY sp.Name, Win_Rank;

-- ============================================
-- QUERY 10
-- Question: List each team's name along with its sport, head coach,
--           and manager in a single row.
-- SQL Features: Multiple JOINs across four tables
-- ============================================
SELECT t.Name AS Team,
       sp.Name AS Sport,
       c.First_Name || ' ' || c.Last_Name AS Head_Coach,
       m.First_Name || ' ' || m.Last_Name AS Manager
FROM TEAMS t
JOIN SPORTS sp   ON t.Sport_ID = sp.Sport_ID
LEFT JOIN COACHES c   ON t.Coach_ID = c.Coach_ID
LEFT JOIN MANAGERS m  ON t.Manager_ID = m.Manager_ID
ORDER BY sp.Name, t.Name;

-- ============================================
-- ============================================
-- SCHEMA LIMITATION NOTES
-- ============================================
-- ============================================

-- LIMITATION 1: Historical coach assignments
-- -------------------------------------------
-- Question the schema cannot answer well:
--   "Which coach has the best win rate as a head coach over the
--    past three seasons?"
--
-- Why it cannot be answered:
--   The TEAMS table stores only the CURRENT Coach_ID for each team.
--   If a coach was replaced mid-season, the previous assignment is
--   lost. There is no history of who coached which team when.
--
-- Schema change required:
--   Add a TEAM_COACH_HISTORY table with columns (Team_ID, Coach_ID,
--   Start_Date, End_Date). This would allow queries over historical
--   coaching assignments.

-- LIMITATION 2: University teams vs. opponent teams
-- -----------------------------------------------
-- Question the schema cannot answer well:
--   "Which teams in the database are official university teams
--    versus opponents we played against?"
--
-- Why it cannot be answered:
--   The TEAMS table stores both university teams and opponent teams
--   in the same entity with no distinguishing flag. In the seed
--   data, only university teams have enrolled students, so some
--   queries (like Q2) filter university teams indirectly by checking
--   which teams have students.
--
-- Schema change required:
--   Add a boolean column Is_University_Team BOOLEAN NOT NULL DEFAULT
--   TRUE to the TEAMS table. Queries could then filter directly on
--   this flag rather than inferring from enrollment.
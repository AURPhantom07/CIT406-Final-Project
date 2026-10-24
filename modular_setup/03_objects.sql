-- ============================================================
-- SECTION 3: VIEWS
-- ============================================================

-- 3.1 game_results_view
-- Combines games, teams, and locations into one row per game,
-- showing home team, away team, score, location, and date.
CREATE OR REPLACE VIEW game_results_view AS
SELECT
    g.Game_ID,
    g.DateTime,
    g.Game_Type,
    home_t.Name    AS Home_Team,
    away_t.Name    AS Away_Team,
    g.Home_Score,
    g.Away_Score,
    l.Name         AS Location,
    g.Attendance
FROM GAMES g
JOIN GAME_TEAMS home_gt ON g.Game_ID = home_gt.Game_ID AND home_gt.HomeOrAway = 'Home'
JOIN TEAMS      home_t  ON home_gt.Team_ID = home_t.Team_ID
JOIN GAME_TEAMS away_gt ON g.Game_ID = away_gt.Game_ID AND away_gt.HomeOrAway = 'Away'
JOIN TEAMS      away_t  ON away_gt.Team_ID = away_t.Team_ID
JOIN LOCATIONS  l       ON g.Location_ID = l.Location_ID;

-- 3.2 coach_practice_load
-- Summarizes each coach's total practice count and minutes.
CREATE OR REPLACE VIEW coach_practice_load AS
SELECT
    c.Coach_ID,
    c.First_Name,
    c.Last_Name,
    COUNT(pc.Practice_ID) AS Total_Practices,
    COALESCE(SUM(p.Duration_Minutes), 0) AS Total_Minutes
FROM COACHES c
LEFT JOIN PRACTICE_COACHES pc ON c.Coach_ID = pc.Coach_ID
LEFT JOIN PRACTICES p ON pc.Practice_ID = p.Practice_ID
GROUP BY c.Coach_ID, c.First_Name, c.Last_Name;


-- ============================================================
-- SECTION 4: FUNCTION
-- ============================================================

-- 4.1 team_avg_home_attendance
-- Returns the average attendance for a given team's home games.
CREATE OR REPLACE FUNCTION team_avg_home_attendance(team_id_input INT)
RETURNS NUMERIC AS $$
DECLARE
    avg_att NUMERIC;
BEGIN
    SELECT AVG(g.Attendance)
    INTO avg_att
    FROM GAMES g
    JOIN GAME_TEAMS gt ON g.Game_ID = gt.Game_ID
    WHERE gt.Team_ID = team_id_input
      AND gt.HomeOrAway = 'Home';
    
    RETURN avg_att;
END;
$$ LANGUAGE plpgsql;


-- ============================================================
-- SECTION 5: AUDIT TRIGGER
-- ============================================================

-- 5.1 Audit log table
CREATE TABLE AUDIT_LOG (
    Audit_ID        SERIAL PRIMARY KEY,
    Table_Name      VARCHAR(50) NOT NULL,
    Record_ID       INT NOT NULL,
    Column_Changed  VARCHAR(50) NOT NULL,
    Old_Value       VARCHAR(100),
    New_Value       VARCHAR(100),
    Changed_By      VARCHAR(100) NOT NULL,
    Changed_At      TIMESTAMP NOT NULL DEFAULT NOW()
);

-- 5.2 Trigger function
CREATE OR REPLACE FUNCTION audit_team_record_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.Win_Count IS DISTINCT FROM NEW.Win_Count THEN
        INSERT INTO AUDIT_LOG 
            (Table_Name, Record_ID, Column_Changed, Old_Value, New_Value, Changed_By, Changed_At)
        VALUES 
            ('TEAMS', NEW.Team_ID, 'Win_Count', 
             OLD.Win_Count::TEXT, NEW.Win_Count::TEXT, 
             CURRENT_USER, NOW());
    END IF;
    
    IF OLD.Loss_Count IS DISTINCT FROM NEW.Loss_Count THEN
        INSERT INTO AUDIT_LOG 
            (Table_Name, Record_ID, Column_Changed, Old_Value, New_Value, Changed_By, Changed_At)
        VALUES 
            ('TEAMS', NEW.Team_ID, 'Loss_Count', 
             OLD.Loss_Count::TEXT, NEW.Loss_Count::TEXT, 
             CURRENT_USER, NOW());
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 5.3 Attach the trigger
CREATE TRIGGER team_record_audit_trigger
AFTER UPDATE ON TEAMS
FOR EACH ROW
EXECUTE FUNCTION audit_team_record_changes();

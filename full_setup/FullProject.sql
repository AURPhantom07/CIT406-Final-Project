-- ============================================================
-- FULLPROJECT.SQL
-- Athletics Management System — Complete Rebuild
-- CIT 406 Term Project
--
-- This file rebuilds the entire database from scratch:
--   1. Drops all existing tables and objects
--   2. Creates the schema
--   3. Seeds the data
--   4. Adds views, function, audit trigger, transaction examples
--
-- Run this file in the Supabase SQL Editor (or pgAdmin).
-- ============================================================


-- ============================================================
-- SECTION 0: CLEANUP
-- Drops everything so this file is safe to re-run.
-- ============================================================
DROP TRIGGER IF EXISTS team_record_audit_trigger ON TEAMS;
DROP FUNCTION IF EXISTS audit_team_record_changes();
DROP FUNCTION IF EXISTS team_avg_home_attendance(INT);
DROP VIEW IF EXISTS game_results_view;
DROP VIEW IF EXISTS coach_practice_load;
DROP TABLE IF EXISTS AUDIT_LOG;

DROP TABLE IF EXISTS PRACTICE_COACHES CASCADE;
DROP TABLE IF EXISTS GAME_TEAMS CASCADE;
DROP TABLE IF EXISTS PRACTICES CASCADE;
DROP TABLE IF EXISTS GAMES CASCADE;
DROP TABLE IF EXISTS STUDENTS CASCADE;
DROP TABLE IF EXISTS TEAMS CASCADE;
DROP TABLE IF EXISTS COACHES CASCADE;
DROP TABLE IF EXISTS MANAGERS CASCADE;
DROP TABLE IF EXISTS SPORTS CASCADE;
DROP TABLE IF EXISTS LOCATIONS CASCADE;

-- Role removal
DROP ROLE IF EXISTS athletics_viewer;
DROP ROLE IF EXISTS athletics_manager;
DROP ROLE IF EXISTS coach_falcons;
DROP ROLE IF EXISTS coach_hawks;

-- ============================================================
-- SECTION 1: SCHEMA
-- ============================================================

-- 1.1 SPORTS
CREATE TABLE SPORTS (
    Sport_ID         SERIAL PRIMARY KEY,
    Name             VARCHAR(100) NOT NULL,
    Season           VARCHAR(20)  NOT NULL,
    Max_Roster_Size  INT          NOT NULL,
    Gender_League    VARCHAR(20)  NOT NULL
);

-- 1.2 COACHES
CREATE TABLE COACHES (
    Coach_ID             SERIAL PRIMARY KEY,
    First_Name           VARCHAR(50) NOT NULL,
    Last_Name            VARCHAR(50) NOT NULL,
    Email                VARCHAR(100),
    Phone_Number         VARCHAR(20),
    Certification_Level  VARCHAR(50),
    Hire_Date            DATE
);

-- 1.3 MANAGERS
CREATE TABLE MANAGERS (
    Manager_ID    SERIAL PRIMARY KEY,
    First_Name    VARCHAR(50) NOT NULL,
    Last_Name     VARCHAR(50) NOT NULL,
    Email         VARCHAR(100),
    Office_Phone  VARCHAR(20)
);

-- 1.4 LOCATIONS
CREATE TABLE LOCATIONS (
    Location_ID   SERIAL PRIMARY KEY,
    Name          VARCHAR(100) NOT NULL,
    Address       VARCHAR(200) NOT NULL,
    Capacity      INT,
    Surface_Type  VARCHAR(50),
    Is_Indoor     BOOLEAN NOT NULL DEFAULT FALSE
);

-- 1.5 TEAMS
CREATE TABLE TEAMS (
    Team_ID     SERIAL PRIMARY KEY,
    Name        VARCHAR(100) NOT NULL,
    Gender      VARCHAR(20),
    Age_Group   VARCHAR(20),
    Season      VARCHAR(20),
    Win_Count   INT DEFAULT 0,
    Loss_Count  INT DEFAULT 0,
    Sport_ID    INT NOT NULL,
    Coach_ID    INT,
    Manager_ID  INT,
    FOREIGN KEY (Sport_ID)   REFERENCES SPORTS(Sport_ID)     ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (Coach_ID)   REFERENCES COACHES(Coach_ID)    ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (Manager_ID) REFERENCES MANAGERS(Manager_ID) ON DELETE SET NULL ON UPDATE CASCADE
);

-- 1.6 STUDENTS
CREATE TABLE STUDENTS (
    Student_ID     SERIAL PRIMARY KEY,
    First_Name     VARCHAR(50) NOT NULL,
    Last_Name      VARCHAR(50) NOT NULL,
    Date_of_Birth  DATE,
    Grade_Level    VARCHAR(20),
    Email          VARCHAR(100),
    Phone_Number   VARCHAR(20),
    Team_ID        INT,
    FOREIGN KEY (Team_ID) REFERENCES TEAMS(Team_ID) ON DELETE SET NULL ON UPDATE CASCADE
);

-- 1.7 GAMES
CREATE TABLE GAMES (
    Game_ID      SERIAL PRIMARY KEY,
    DateTime     TIMESTAMP NOT NULL,
    Game_Type    VARCHAR(50),
    Home_Score   INT,
    Away_Score   INT,
    Attendance   INT,
    Location_ID  INT NOT NULL,
    FOREIGN KEY (Location_ID) REFERENCES LOCATIONS(Location_ID) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 1.8 GAME_TEAMS (junction)
CREATE TABLE GAME_TEAMS (
    Game_ID     INT NOT NULL,
    Team_ID     INT NOT NULL,
    HomeOrAway  VARCHAR(10) NOT NULL CHECK (HomeOrAway IN ('Home', 'Away')),
    PRIMARY KEY (Game_ID, Team_ID),
    FOREIGN KEY (Game_ID) REFERENCES GAMES(Game_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Team_ID) REFERENCES TEAMS(Team_ID) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 1.9 PRACTICES
CREATE TABLE PRACTICES (
    Practice_ID       SERIAL PRIMARY KEY,
    DateTime          TIMESTAMP NOT NULL,
    Duration_Minutes  INT,
    Focus_Area        VARCHAR(100),
    Is_Mandatory      BOOLEAN DEFAULT FALSE,
    Team_ID           INT NOT NULL,
    Location_ID       INT NOT NULL,
    FOREIGN KEY (Team_ID)     REFERENCES TEAMS(TEAM_ID)         ON DELETE CASCADE  ON UPDATE CASCADE,
    FOREIGN KEY (Location_ID) REFERENCES LOCATIONS(Location_ID) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 1.10 PRACTICE_COACHES (junction)
CREATE TABLE PRACTICE_COACHES (
    Practice_ID  INT NOT NULL,
    Coach_ID     INT NOT NULL,
    PRIMARY KEY (Practice_ID, Coach_ID),
    FOREIGN KEY (Practice_ID) REFERENCES PRACTICES(PRACTICE_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Coach_ID)    REFERENCES COACHES(COACH_ID)      ON DELETE CASCADE ON UPDATE CASCADE
);

-- 1.11 Disable RLS (Supabase enables it by default)
ALTER TABLE SPORTS           DISABLE ROW LEVEL SECURITY;
ALTER TABLE COACHES          DISABLE ROW LEVEL SECURITY;
ALTER TABLE MANAGERS         DISABLE ROW LEVEL SECURITY;
ALTER TABLE LOCATIONS        DISABLE ROW LEVEL SECURITY;
ALTER TABLE TEAMS            DISABLE ROW LEVEL SECURITY;
ALTER TABLE STUDENTS         DISABLE ROW LEVEL SECURITY;
ALTER TABLE GAMES            DISABLE ROW LEVEL SECURITY;
ALTER TABLE GAME_TEAMS       DISABLE ROW LEVEL SECURITY;
ALTER TABLE PRACTICES        DISABLE ROW LEVEL SECURITY;
ALTER TABLE PRACTICE_COACHES DISABLE ROW LEVEL SECURITY;


-- ============================================================
-- SECTION 2: SEED DATA
-- ============================================================

-- 2.1 SPORTS
INSERT INTO SPORTS (Name, Season, Max_Roster_Size, Gender_League) VALUES
('Basketball', 'Winter', 15, 'Men'),
('Soccer',     'Fall',   22, 'Women'),
('Volleyball', 'Fall',   14, 'Women'),
('Baseball',   'Spring', 25, 'Men'),
('Tennis',     'Spring', 12, 'Women'),
('Track',      'Spring', 30, 'Co-ed');

-- 2.2 COACHES
INSERT INTO COACHES (First_Name, Last_Name, Email, Phone_Number, Certification_Level, Hire_Date) VALUES
('John',   'Smith',   'jsmith@athletics.edu',   '305-111-2222', 'Level 3', '2020-08-15'),
('Sarah',  'Johnson', 'sjohnson@athletics.edu', '786-333-4444', 'Level 2', '2021-06-01'),
('Mike',   'Davis',   'mdavis@athletics.edu',   '305-555-7777', 'Level 1', '2022-01-10'),
('Emily',  'Garcia',  'egarcia@athletics.edu',  '786-888-9999', 'Level 3', '2019-05-20'),
('Marcus', 'Lee',     'mlee@athletics.edu',     '305-222-3333', 'Level 2', '2021-09-12'),
('Priya',  'Nair',    'pnair@athletics.edu',    '786-444-5555', 'Level 3', '2018-03-05'),
('Tom',    'Nguyen',  'tnguyen@athletics.edu',  '305-666-7777', 'Level 1', '2023-01-20'),
('Rosa',   'Reyes',   'rreyes@athletics.edu',   '786-999-0000', 'Level 2', '2022-07-01');

-- 2.3 MANAGERS
INSERT INTO MANAGERS (First_Name, Last_Name, Email, Office_Phone) VALUES
('Robert', 'Brown',    'rbrown@athletics.edu',   '305-000-1111'),
('Linda',  'Martinez', 'lmartinez@athletics.edu','305-000-2222'),
('Kevin',  'O''Brien', 'kobrien@athletics.edu',  '305-000-3333');

-- 2.4 LOCATIONS
INSERT INTO LOCATIONS (Name, Address, Capacity, Surface_Type, Is_Indoor) VALUES
('Main Gym',      '123 Campus Dr',      500,  'Hardwood', FALSE),
('West Field',    '456 Stadium Way',    1000, 'Grass',    FALSE),
('East Court',    '789 Arena Blvd',     300,  'Hardwood', TRUE),
('North Diamond', '321 Diamond Rd',     800,  'Dirt',     FALSE),
('South Tennis',  '654 Baseline Ave',   200,  'Hardcourt',FALSE),
('Track Arena',   '987 Oval Lane',      1500, 'Rubber',   FALSE);

-- 2.5 TEAMS
INSERT INTO TEAMS (Name, Gender, Age_Group, Season, Win_Count, Loss_Count, Sport_ID, Coach_ID, Manager_ID) VALUES
('Falcons',    'Men',   'Varsity', 'Winter 2024', 12, 3,  1, 1, 1),
('Hawks',      'Women', 'Varsity', 'Fall 2024',   10, 5,  2, 2, 1),
('Eagles',     'Women', 'JV',      'Fall 2024',    8, 6,  3, 3, 2),
('Panthers',   'Men',   'Varsity', 'Spring 2025', 15, 2,  4, 4, 2),
('Lions',      'Women', 'Varsity', 'Fall 2024',   11, 4,  2, 5, 1),
('Tigers',     'Men',   'Varsity', 'Winter 2024',  9, 6,  1, 6, 1),
('Bears',      'Women', 'Varsity', 'Fall 2024',    7, 7,  3, 7, 3),
('Sharks',     'Men',   'JV',      'Winter 2024',  6, 8,  1, 1, 1),
('Comets',     'Women', 'Varsity', 'Spring 2025', 13, 2,  5, 5, 2),
('Stallions',  'Men',   'Varsity', 'Spring 2025', 14, 1,  6, 6, 3);

-- 2.6 STUDENTS
INSERT INTO STUDENTS (First_Name, Last_Name, Date_of_Birth, Grade_Level, Email, Phone_Number, Team_ID) VALUES
('Maria',   'Lopez',    '2006-03-12', 'Senior',     'mlopez@student.edu',    '305-111-1111', 1),
('James',   'Wilson',   '2007-07-22', 'Junior',     'jwilson@student.edu',   '786-222-2222', 1),
('Aisha',   'Patel',    '2006-11-05', 'Senior',     'apatel@student.edu',    '305-333-3333', 2),
('Carlos',  'Ramirez',  '2008-01-30', 'Sophomore',  'cramirez@student.edu',  '786-444-4444', 2),
('Nina',    'Chen',     '2007-09-14', 'Junior',     'nchen@student.edu',     '305-555-5555', 3),
('David',   'Kim',      '2006-05-18', 'Senior',     'dkim@student.edu',      '786-666-6666', 4),
('Sofia',   'Reyes',    '2007-02-11', 'Junior',     'sreyes@student.edu',    '305-777-1001', 1),
('Ethan',   'Brooks',   '2006-09-03', 'Senior',     'ebrooks@student.edu',   '786-777-1002', 1),
('Olivia',  'Turner',   '2008-04-25', 'Sophomore',  'oturner@student.edu',   '305-777-1003', 2),
('Liam',    'Cooper',   '2007-12-08', 'Junior',     'lcooper@student.edu',   '786-777-1004', 2),
('Amara',   'Okafor',   '2006-07-19', 'Senior',     'aokafor@student.edu',   '305-777-1005', 3),
('Noah',    'Bennett',  '2008-03-14', 'Sophomore',  'nbennett@student.edu',  '786-777-1006', 3),
('Isabella','Flores',   '2007-11-27', 'Junior',     'iflores@student.edu',   '305-777-1007', 4),
('Mason',   'Hughes',   '2006-06-05', 'Senior',     'mhughes@student.edu',   '786-777-1008', 4),
('Zara',    'Ahmed',    '2007-08-22', 'Junior',     'zahmed@student.edu',    '305-777-1009', 5),
('Lucas',   'Silva',    '2006-01-17', 'Senior',     'lsilva@student.edu',    '786-777-1010', 5),
('Maya',    'Singh',    '2008-05-09', 'Sophomore',  'msingh@student.edu',    '305-777-1011', 5),
('Elijah',  'Ward',     '2007-03-30', 'Junior',     'eward@student.edu',     '786-777-1012', 6),
('Chloe',   'Rivera',   '2006-10-12', 'Senior',     'crivera@student.edu',   '305-777-1013', 6),
('Jackson', 'Price',    '2008-02-28', 'Sophomore',  'jprice@student.edu',    '786-777-1014', 6),
('Layla',   'Hassan',   '2007-06-16', 'Junior',     'lhassan@student.edu',   '305-777-1015', 7),
('Henry',   'Foster',   '2006-12-04', 'Senior',     'hfoster@student.edu',   '786-777-1016', 7),
('Aria',    'Morgan',   '2008-07-21', 'Sophomore',  'amorgan@student.edu',   '305-777-1017', 7),
('Owen',    'Reed',     '2007-04-02', 'Junior',     'oreed@student.edu',     '786-777-1018', 8),
('Lily',    'Bell',     '2006-08-26', 'Senior',     'lbell@student.edu',     '305-777-1019', 8),
('Caleb',   'Murphy',   '2008-01-13', 'Sophomore',  'cmurphy@student.edu',   '786-777-1020', 8),
('Grace',   'Kelly',    '2007-10-29', 'Junior',     'gkelly@student.edu',    '305-777-1021', 9),
('Ryan',    'Howard',   '2006-04-11', 'Senior',     'rhoward@student.edu',   '786-777-1022', 9),
('Zoe',     'Barnes',   '2008-08-07', 'Sophomore',  'zbarnes@student.edu',   '305-777-1023', 9),
('Nathan',  'Ross',     '2007-01-23', 'Junior',     'nross@student.edu',     '786-777-1024', 10),
('Hannah',  'Perry',    '2006-09-30', 'Senior',     'hperry@student.edu',    '305-777-1025', 10),
('Dylan',   'Powell',   '2008-06-18', 'Sophomore',  'dpowell@student.edu',   '786-777-1026', 10),
('Ruby',    'Long',     '2007-12-14', 'Junior',     'rlong@student.edu',     '305-777-1027', 1),
('Gabriel', 'Fisher',   '2006-02-07', 'Senior',     'gfisher@student.edu',   '786-777-1028', 2),
('Stella',  'Henderson','2008-03-26', 'Sophomore',  'shenderson@student.edu','305-777-1029', 4),
('Isaac',   'Cole',     '2007-05-15', 'Junior',     'icole@student.edu',     '786-777-1030', 5);

-- 2.7 GAMES
INSERT INTO GAMES (DateTime, Game_Type, Home_Score, Away_Score, Attendance, Location_ID) VALUES
('2024-12-01 18:00:00', 'League',   78, 65, 450,  1),
('2024-12-05 19:30:00', 'League',   82, 80, 500,  1),
('2024-11-10 15:00:00', 'Playoff',   3,  1, 950,  2),
('2024-11-20 16:00:00', 'League',    2,  2, 800,  2),
('2025-03-15 14:00:00', 'Friendly',  5,  4, 600,  4),
('2024-12-08 18:00:00', 'League',   75, 70, 480,  1),
('2024-12-12 19:00:00', 'League',   68, 72, 520,  1),
('2024-12-15 17:30:00', 'League',   80, 78, 610,  1),
('2024-11-12 15:00:00', 'League',    2,  0, 850,  2),
('2024-11-15 16:30:00', 'League',    1,  3, 900,  2),
('2024-11-25 15:00:00', 'League',    4,  2, 780,  2),
('2024-12-01 15:00:00', 'League',    0,  0, 750,  2),
('2024-12-08 15:00:00', 'Playoff',   3,  2, 1100, 2),
('2025-03-18 16:00:00', 'League',    6,  3, 650,  4),
('2025-03-22 14:00:00', 'League',    4,  5, 700,  4),
('2025-04-02 17:00:00', 'League',    8,  2, 500,  5),
('2025-04-05 17:00:00', 'League',    6,  4, 450,  5),
('2025-04-09 17:00:00', 'Playoff',   7,  6, 550,  5),
('2025-04-15 16:00:00', 'League',   92, 88, 620,  6),
('2025-04-18 16:00:00', 'League',   85, 90, 640,  6),
('2025-04-22 16:00:00', 'League',   88, 82, 700,  6),
('2024-12-18 18:30:00', 'League',   72, 75, 470,  1),
('2024-12-22 18:30:00', 'League',   85, 81, 530,  1),
('2025-03-25 14:30:00', 'League',    3,  1, 720,  4),
('2025-04-25 17:30:00', 'Playoff',  10,  4, 580,  5);

-- 2.8 GAME_TEAMS
INSERT INTO GAME_TEAMS (Game_ID, Team_ID, HomeOrAway) VALUES
(1, 1, 'Home'),
(1, 4, 'Away'),
(2, 1, 'Home'),
(2, 4, 'Away'),
(3, 2, 'Home'),
(3, 3, 'Away'),
(4, 2, 'Home'),
(4, 3, 'Away'),
(5, 4, 'Home'),
(5, 1, 'Away'),
(6, 1, 'Home'),
(6, 6, 'Away'),
(7, 1, 'Home'),
(7, 8, 'Away'),
(8, 6, 'Home'),
(8, 1, 'Away'),
(9, 2, 'Home'),
(9, 5, 'Away'),
(10, 5, 'Home'),
(10, 2, 'Away'),
(11, 2, 'Home'),
(11, 3, 'Away'),
(12, 3, 'Home'),
(12, 7, 'Away'),
(13, 2, 'Home'),
(13, 5, 'Away'),
(14, 4, 'Home'),
(14, 10, 'Away'),
(15, 10, 'Home'),
(15, 4, 'Away'),
(16, 9, 'Home'),
(16, 10, 'Away'),
(17, 9, 'Home'),
(17, 10, 'Away'),
(18, 9, 'Home'),
(18, 10, 'Away'),
(19, 6, 'Home'),
(19, 1, 'Away'),
(20, 1, 'Home'),
(20, 6, 'Away'),
(21, 6, 'Home'),
(21, 8, 'Away'),
(22, 1, 'Home'),
(22, 8, 'Away'),
(23, 1, 'Home'),
(23, 6, 'Away'),
(24, 4, 'Home'),
(24, 10, 'Away'),
(25, 9, 'Home'),
(25, 10, 'Away');

-- 2.9 PRACTICES
INSERT INTO PRACTICES (DateTime, Duration_Minutes, Focus_Area, Is_Mandatory, Team_ID, Location_ID) VALUES
('2024-11-25 17:00:00',  90, 'Offense',       TRUE,  1, 1),
('2024-11-27 17:00:00', 120, 'Conditioning',  TRUE,  1, 3),
('2024-11-15 16:00:00',  90, 'Defense',       TRUE,  2, 2),
('2024-11-18 16:00:00',  75, 'Set Pieces',    FALSE, 2, 2),
('2025-03-01 15:00:00', 120, 'Batting',       TRUE,  4, 4),
('2024-11-22 17:00:00',  90, 'Ball Control',  TRUE,  1, 1),
('2024-12-02 17:00:00',  90, 'Free Throws',   FALSE, 1, 1),
('2024-11-12 16:00:00', 105, 'Passing',       TRUE,  2, 2),
('2024-11-20 16:00:00',  90, 'Scrimmage',     TRUE,  2, 2),
('2024-11-23 16:00:00',  75, 'Set Pieces',    FALSE, 5, 2),
('2024-12-05 17:00:00', 100, 'Shooting',      TRUE,  6, 1),
('2024-12-10 17:00:00',  90, 'Defense',       TRUE,  6, 1),
('2024-11-28 16:00:00',  80, 'Serving',       TRUE,  7, 3),
('2024-12-12 17:00:00',  85, 'Rebounds',      TRUE,  8, 1),
('2025-03-10 16:00:00', 110, 'Batting',       TRUE,  4, 4),
('2025-03-15 16:00:00',  95, 'Fielding',      TRUE,  4, 4),
('2025-04-01 15:00:00',  90, 'Forehand',      TRUE,  9, 5),
('2025-04-05 15:00:00',  90, 'Backhand',      TRUE,  9, 5);

-- 2.10 PRACTICE_COACHES
INSERT INTO PRACTICE_COACHES (Practice_ID, Coach_ID) VALUES
(1, 1),
(1, 3),
(2, 1),
(3, 2),
(3, 4),
(4, 2),
(5, 4),
(6, 1),
(7, 1),
(7, 6),
(8, 2),
(9, 2),
(9, 5),
(10, 5),
(11, 6),
(12, 1),
(12, 6),
(13, 7),
(14, 1),
(15, 4),
(16, 4),
(16, 5),
(17, 5),
(18, 5);


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


-- ============================================================
-- SECTION 6: TRANSACTION EXAMPLES (commented)
-- ============================================================
-- This sections has been kept commented out to do the proper testing. 
-- You can uncomment and run these blocks to test transactions.
--

-- 6.1 SUCCESS SCENARIO
-- Records a new game, links both teams, and updates standings
-- in a single atomic transaction.
/*
BEGIN;

INSERT INTO GAMES (DateTime, Game_Type, Home_Score, Away_Score, Attendance, Location_ID)
VALUES ('2026-05-10 18:00:00', 'League', 88, 75, 620, 1);

INSERT INTO GAME_TEAMS (Game_ID, Team_ID, HomeOrAway)
VALUES (currval('games_game_id_seq'), 1, 'Home');

INSERT INTO GAME_TEAMS (Game_ID, Team_ID, HomeOrAway)
VALUES (currval('games_game_id_seq'), 6, 'Away');

UPDATE TEAMS SET Win_Count = Win_Count + 1 WHERE Team_ID = 1;
UPDATE TEAMS SET Loss_Count = Loss_Count + 1 WHERE Team_ID = 6;

COMMIT;
*/

-- 6.2 ROLLBACK SCENARIO
-- Same steps but with an invalid Team_ID, forcing a rollback.
/*
BEGIN;

INSERT INTO GAMES (DateTime, Game_Type, Home_Score, Away_Score, Attendance, Location_ID)
VALUES ('2026-05-10 18:00:00', 'League', 88, 75, 620, 1);

INSERT INTO GAME_TEAMS (Game_ID, Team_ID, HomeOrAway)
VALUES (currval('games_game_id_seq'), 1, 'Home');

-- Will fail: Team 999 does not exist
INSERT INTO GAME_TEAMS (Game_ID, Team_ID, HomeOrAway)
VALUES (currval('games_game_id_seq'), 999, 'Away');

UPDATE TEAMS SET Win_Count = Win_Count + 1 WHERE Team_ID = 1;
UPDATE TEAMS SET Loss_Count = Loss_Count + 1 WHERE Team_ID = 6;

COMMIT;
*/


-- ============================================================
-- SECTION 7: SECURITY POLICIES (ROLES & RLS)
-- ============================================================

-- 7.1 Create the Application Roles
CREATE ROLE athletics_viewer WITH LOGIN PASSWORD 'viewer123';
CREATE ROLE athletics_manager WITH LOGIN PASSWORD 'manager123';

-- 7.2 Grant privileges to Viewer (Read-only)
GRANT USAGE ON SCHEMA public TO athletics_viewer;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO athletics_viewer;

-- 7.3 Grant privileges to Manager (Read/Write)
GRANT USAGE ON SCHEMA public TO athletics_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO athletics_manager;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO athletics_manager;

-- 7.4 Create Coach Roles for Row Level Security (RLS)
CREATE ROLE coach_falcons;
CREATE ROLE coach_hawks;

GRANT SELECT ON STUDENTS TO coach_falcons, coach_hawks;

-- 7.5 Enable RLS on the STUDENTS table
ALTER TABLE STUDENTS ENABLE ROW LEVEL SECURITY;

-- 7.6 Create the RLS Policy
-- This ensures Coaches can only see the students on their own team.
CREATE POLICY coach_student_access ON STUDENTS
FOR SELECT
USING (
    (CURRENT_USER = 'coach_falcons' AND Team_ID = 1) OR
    (CURRENT_USER = 'coach_hawks' AND Team_ID = 2)
);
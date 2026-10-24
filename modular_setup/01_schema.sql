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


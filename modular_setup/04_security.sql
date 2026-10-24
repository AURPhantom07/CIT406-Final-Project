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
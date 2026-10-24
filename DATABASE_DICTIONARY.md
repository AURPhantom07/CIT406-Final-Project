# Data Dictionary: Athletics Management System

This document describes the structure of the Athletics Management System database, including every table, column, data type, constraints, and a brief description of its purpose.

---

## 1. Table: SPORTS
**Description:** Represents the distinct athletic programs offered by the university.

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| **Sport_ID** | SERIAL | PRIMARY KEY | Unique identifier for the sport. |
| **Name** | VARCHAR(100) | NOT NULL | The name of the sport (e.g., "Basketball"). |
| **Season** | VARCHAR(20) | NOT NULL | The season the sport is played in (e.g., "Winter", "Fall"). |
| **Max_Roster_Size** | INT | NOT NULL | The maximum number of players allowed on a team. |
| **Gender_League** | VARCHAR(20) | NOT NULL | The gender division (e.g., "Men", "Women", "Co-ed"). |

---

## 2. Table: COACHES
**Description:** Represents the coaching staff employed by the athletics department.

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| **Coach_ID** | SERIAL | PRIMARY KEY | Unique identifier for the coach. |
| **First_Name** | VARCHAR(50) | NOT NULL | The coach's first name. |
| **Last_Name** | VARCHAR(50) | NOT NULL | The coach's last name. |
| **Email** | VARCHAR(100) | | The coach's email address. |
| **Phone_Number** | VARCHAR(20) | | The coach's contact number. |
| **Certification_Level**| VARCHAR(50) | | The coach's highest certification (e.g., "Level 3"). |
| **Hire_Date** | DATE | | The date the coach was hired by the university. |

---

## 3. Table: MANAGERS
**Description:** Represents the athletics department staff who oversee teams.

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| **Manager_ID** | SERIAL | PRIMARY KEY | Unique identifier for the manager. |
| **First_Name** | VARCHAR(50) | NOT NULL | The manager's first name. |
| **Last_Name** | VARCHAR(50) | NOT NULL | The manager's last name. |
| **Email** | VARCHAR(100) | | The manager's email address. |
| **Office_Phone** | VARCHAR(20) | | The manager's office phone number. |

---

## 4. Table: LOCATIONS
**Description:** Represents the physical venues where games and practices are held.

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| **Location_ID** | SERIAL | PRIMARY KEY | Unique identifier for the location. |
| **Name** | VARCHAR(100) | NOT NULL | The name of the venue (e.g., "Main Gym"). |
| **Address** | VARCHAR(200) | NOT NULL | The physical address of the venue. |
| **Capacity** | INT | | The maximum number of spectators allowed. |
| **Surface_Type** | VARCHAR(50) | | The playing surface (e.g., "Hardwood", "Grass"). |
| **Is_Indoor** | BOOLEAN | NOT NULL, DEFAULT FALSE | True if the venue is indoors, False if outdoors. |

---

## 5. Table: TEAMS
**Description:** Represents specific athletic teams within a sport.

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| **Team_ID** | SERIAL | PRIMARY KEY | Unique identifier for the team. |
| **Name** | VARCHAR(100) | NOT NULL | The team's name (e.g., "Falcons"). |
| **Gender** | VARCHAR(20) | | The team's gender division. |
| **Age_Group** | VARCHAR(20) | | The competitive level (e.g., "Varsity", "JV"). |
| **Season** | VARCHAR(20) | | The specific season the team represents (e.g., "Fall 2024"). |
| **Win_Count** | INT | DEFAULT 0 | Total current wins. |
| **Loss_Count** | INT | DEFAULT 0 | Total current losses. |
| **Sport_ID** | INT | FOREIGN KEY | References SPORTS(Sport_ID). ON DELETE RESTRICT. |
| **Coach_ID** | INT | FOREIGN KEY | References COACHES(Coach_ID). ON DELETE SET NULL. |
| **Manager_ID** | INT | FOREIGN KEY | References MANAGERS(Manager_ID). ON DELETE SET NULL. |

---

## 6. Table: STUDENTS
**Description:** Represents the student-athletes enrolled at the university.

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| **Student_ID** | SERIAL | PRIMARY KEY | Unique identifier for the student. |
| **First_Name** | VARCHAR(50) | NOT NULL | The student's first name. |
| **Last_Name** | VARCHAR(50) | NOT NULL | The student's last name. |
| **Date_of_Birth** | DATE | | The student's birth date. |
| **Grade_Level** | VARCHAR(20) | | Academic standing (e.g., "Freshman", "Senior"). |
| **Email** | VARCHAR(100) | | The student's email address. |
| **Phone_Number** | VARCHAR(20) | | The student's contact number. |
| **Team_ID** | INT | FOREIGN KEY | References TEAMS(Team_ID). ON DELETE SET NULL. |

---

## 7. Table: GAMES
**Description:** Represents a scheduled competition between two teams.

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| **Game_ID** | SERIAL | PRIMARY KEY | Unique identifier for the game. |
| **DateTime** | TIMESTAMP | NOT NULL | The date and time the game is scheduled. |
| **Game_Type** | VARCHAR(50) | | The type of game (e.g., "League", "Playoff"). |
| **Home_Score** | INT | | The final score for the home team. |
| **Away_Score** | INT | | The final score for the away team. |
| **Attendance** | INT | | The number of spectators at the game. |
| **Location_ID** | INT | FOREIGN KEY | References LOCATIONS(Location_ID). ON DELETE RESTRICT. |

---

## 8. Table: GAME_TEAMS (Junction Table)
**Description:** Resolves the Many-to-Many relationship between Games and Teams.

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| **Game_ID** | INT | PRIMARY KEY, FK | References GAMES(Game_ID). ON DELETE CASCADE. |
| **Team_ID** | INT | PRIMARY KEY, FK | References TEAMS(Team_ID). ON DELETE CASCADE. |
| **HomeOrAway** | VARCHAR(10) | NOT NULL, CHECK | Must be either 'Home' or 'Away'. Indicates team's role. |

---

## 9. Table: PRACTICES
**Description:** Represents a scheduled training session for a specific team.

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| **Practice_ID** | SERIAL | PRIMARY KEY | Unique identifier for the practice. |
| **DateTime** | TIMESTAMP | NOT NULL | The date and time the practice begins. |
| **Duration_Minutes**| INT | | Length of the practice in minutes. |
| **Focus_Area** | VARCHAR(100) | | The primary tactical focus (e.g., "Offense"). |
| **Is_Mandatory** | BOOLEAN | DEFAULT FALSE | True if attendance is required. |
| **Team_ID** | INT | FOREIGN KEY | References TEAMS(Team_ID). ON DELETE CASCADE. |
| **Location_ID** | INT | FOREIGN KEY | References LOCATIONS(Location_ID). ON DELETE RESTRICT. |

---

## 10. Table: PRACTICE_COACHES (Junction Table)
**Description:** Resolves the Many-to-Many relationship between Practices and Coaches.

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| **Practice_ID** | INT | PRIMARY KEY, FK | References PRACTICES(Practice_ID). ON DELETE CASCADE. |
| **Coach_ID** | INT | PRIMARY KEY, FK | References COACHES(Coach_ID). ON DELETE CASCADE. |

---

## 11. Table: AUDIT_LOG
**Description:** Records changes made to sensitive data (specifically, Win/Loss counts in the TEAMS table) for accountability.

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| **Audit_ID** | SERIAL | PRIMARY KEY | Unique identifier for the log entry. |
| **Table_Name** | VARCHAR(50) | NOT NULL | The name of the table that was modified. |
| **Record_ID** | INT | NOT NULL | The Primary Key of the row that was modified. |
| **Column_Changed** | VARCHAR(50) | NOT NULL | The name of the specific column that changed. |
| **Old_Value** | VARCHAR(100) | | The value before the update. |
| **New_Value** | VARCHAR(100) | | The value after the update. |
| **Changed_By** | VARCHAR(100) | NOT NULL | The PostgreSQL user who executed the update. |
| **Changed_At** | TIMESTAMP | NOT NULL, DEFAULT NOW()| The exact date and time the change occurred. |
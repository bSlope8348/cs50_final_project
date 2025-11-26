# JumpSim (A CS50 Final Project)
A platform game made in Lua with the LÖVE2d framework that records and displays records in a SQLite3 database.

### Video Demo: [CS50 Final Project - JumpSim](https://www.youtube.com/watch?v=HyP1KF5kuiE)

## Project Overview
This project was created to learn the coding language Lua, learn how to make a 2d game, and implement data logging using SQL. The following was the intended scope of the project.

1.	Learn about basic game development
2.	Learn the basics of the coding language Lua alongside the framework LÖVE2d
3.	Build a 2d platformer implementing various rules and UI elements
4.	Integrate a SQLite3 database for logging player actions/scores and to create a leaderboard. 

-	More than one level was originally in the scope but was cut for purposes of time. This could be implemented in the future to allow a proper tutorial experience for the player, a proper explanation of the controls, or for multiple levels and leaderboards. 

The final project contains a playable build (for Windows32/64, Web, MacOS, and Linux) and all of the source code. Version 1.2 of the game is the final version submitted. 

### Running the Game:

Windows Example: 

The builds folder for version 1.2 (...\cs50_final_project\builds\1.2) contains the executables. For a Windows 64-bit system, if LÖVE is already installed on the system then the file "JumpSim.love" can be run inside the "love" sub-folder. Otherwise, the file "JumpSim-win64.zip" inside the sub-folder "win64" must be unzipped and then run the file "JumpSim.exe".

On Windows this will create a sub-directory in the user's profile: ...\user\AppData\Roaming\LOVE\JumpSim

In this folder is where the database "gameDB.db" and save file "quicksave.txt" will be stored.

## The Game
The game starts with asking for the current player's name and then allows the player to figure out how to play on their own. Upon trial and error, the player will find two playable characters, a coin, a movable box, and a grayed out exit. There are also walls and floors to the level. The latter of which has multiple options (one of which the player can fall through). 

Ultimately, the player will find out they need to collect the coin with one of the characters, and then that character will need to reach the exit to complete the level. There is also a timer in the level to let the player know how long it has taken them. 

A pause menu is also implemented with multiple options: resume, save, load, top scores, restart, and exit. While paused, the game timer will also pause. The following is an explanation of each item:
1.	Resume: Resumes the game from the current state.
2.	Save: Creates a save state (only one save available) of the current game (timer and objects).
3.	Load: Loads the last saved state if one is available. 
4.	Top Scores: Shows the top 10 shortest times on their machine (local SQL database).
5.	Restart: Starts the game over including asking for the player's name.
6.	Exit: Closes the game. 

## Controls
A mouse and keyboard are required to properly play the game.

Mouse: 
-	Left Click: Used for selecting options in the menus. 

Keyboard: 
-	"Left" or "A": Move character to the left.
-	"Right" or "D": Move character to the right.
-	"Up" or "Space": Have the character jump.
-	"Esc": Pull up the pause menu.
-	Full Keyboard: Used to type player's name.

## SQLite3 Database
The game creates a local SQLite3 database (or opens one if available) upon starting the game. Upon finishing the level a table is used (or created) to log the player's name, time completed, first move, and date. This is used to keep track of all the games played on the local machine running the game. When "Top Scores" is selected in the pause menu the database is queried for the top 10 scores based on time completed and displayed to the player. It is also used to let the player know their current rank upon completing the game.

A library "sqlite3.lua" was used to integrate SQLite3 into the games code to CREATE/OPEN a database, INSERT completion logs, SELECT top scores to display, and CLOSE the database upon game exit. Care was taken to write proper code to avoid any sql injection attacks by the user via naming conventions with strings. 

### Queries Used:
```sql
CREATE TABLE IF NOT EXISTS log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    time_completed REAL,
    first_key_used TEXT,
    date_logged INTEGER
);
```

```sql
SELECT COUNT(*) as rank 
FROM log 
WHERE time_completed > 0 
	AND time_completed < %f 
	AND time_completed IS NOT NULL;
```

```sql
SELECT * 
FROM log 
WHERE time_completed > 0 
	AND time_completed IS NOT NULL 
ORDER BY time_completed ASC 
LIMIT 10;
```

```lua
string.format("INSERT INTO log (name, time_completed, first_key_used, date_logged) VALUES ('%s', %f, '%s', %d)", 
	escapeSQLString(playerName), timeCompleted, escapeSQLString(firstKey), os.time())
```

## Code and Structure
The basic folder/file structure was created using "LOVE-VSCode-Game-Template" via GitHub.

```
cs50_final_project
|
├── /Game
│   ├── /assets			Contains the game's assets (.png)
│   ├── /lib			Contains external libraries
│   ├── /src			Contains the game's source code
│   |	└── /ui			Contains the game's user interface code
│	│
│   ├── conf.lua		Configuration for lua and love
│   └── main.lua		The main program file
│
├── /Tools
│   ├── /build			Contains the makelove.toml
│   └── package.json	Contains all scripts to use with NPM Scripts
│
├── /Resources			Contains resources for game that should not be shipped
│
├── /Builds				Contains the builds of game made with makelove
│   ├── /1.0			version 1.0 build for lovejs, macos, win32, win64
│   ├── /1.1			version 1.1 build for linux
│   └── /1.2			version 1.2 (final) build for lovejs, macos, win32, win64
│
└── Root				Root access to the workspace
```

### File Descriptions: 

#### Source Code:
-	**main.lua**: Main program that runs combination of all source code and libraries. Contains the main love.load(), love.update(dt), and love.draw() functions. Also, it contains the save/load, keypressed, and other various funcions. love.load() loads all the necessary libraries and variables. love.update(dt) runs every frame. love.draw() tells what to be drawn on the screen. This also contains the code for the level layout and handling the SQLite3 database calls via the sqlite3.lua library. 
-	**conf.lua**: Contains all the variables for how the game runs and for lua/love.
-	**entity.lua**: Uses the classic.lua library for object oriented functions and is the base class for all other objects. This code also handles the collision between all objects based on position and weight. 
-	**box.lua, coin.lua, exit.lua, floor.lua, player.lua, thruFloor.lua, wall.lua**: These are all extensions of entity.lua. They are called in main.lua to create various objects for the level. 
-	**name.lua**: This takes user input to store the players name via the InputField.lua library.
-	**pause.lua**: The pause screen that handles all the menu actions. This includes linking to save/load and pulling the database to show top scores.
-	**scoreBox.lua**: Used to create a timing score for the user to see. 

#### Main Libraries:
-	**classic.lua**: Used to create classes like entity.lua.
-	**InputField.lua**: Used for simple text input fields from the user.
-	**sqlite3.lua**: A library used to handle SQLite3 databases in Lua. 

### Building the Game:
**makelove** is a packaging tool for love games that was used to build the source code into executables for different platforms. 

## Known Bugs
Collision between objects was found to be particularly difficult to solve. Most collisions are functioning properly, but it has been found that if there are multiple playable characters interacting with a box that sometimes one character may be able to push the box through the other character causing that character to "pop" out of the box. This is rare but possible. 

## Credits and Documentation
The following are the items that were used in the creation of this project. A note on the use of AI: ChatGPT was mainly used for help on installation of software, to verify if ideas were a good direction to follow, and what libraries in lua were available. Claude was mainly used for help with code issues. Code used was either sourced from the following or of my own creation. AI was only used for help on bugs or suggestions and not to write the project code itself. 

-	Making Small-Scale 2D Games with LÖVE 2D and Lua - CS50 Seminars 2021: https://www.youtube.com/watch?v=iOA5YspoJDM

-	How to LÖVE by Sheepolution:  https://sheepolution.com/learn/book/contents

-	Visual Studio Code: https://code.visualstudio.com/

-	LÖVE2d with Lua: https://www.love2d.org/

-	Game Template: https://github.com/Keyslam/LOVE-VSCode-Game-Template

-	Lua libraries used:
	-	classic.lua https://github.com/rxi/classic
	-	InputField.lua https://github.com/ReFreezed/InputField
	-	sqlite3.lua https://github.com/CentauriSoldier/SQLite3-for-Lua

-	makelove (for building the game): https://github.com/pfirsich/makelove

-	Game Assets: https://kenney.nl/

-	AI Assitance:
	-	ChatGPT	https://chatgpt.com/
	-	Claude	https://claude.ai/

## Appendix

### 1. CS50 Final Project Ideas
1.  A web-based application using JavaScript, Python, and SQL.
    - Possibly an app used to track calendars and share with others, or grouping of things like concerts or get togethers.
2.	Android app (using Java?)
    - Like idea 1?
    - Can you do idea 4 and put in Android
        - May need Android Studio or Gradle to build.
3.  Chrome extension using JavaScript
    - Like idea 1?
4.	Game using Lua (simple scripting language [looks like python to me]) with LÖVE (aka Love2D: free, open source 2D game engine) {Make into Web app and Android app?}
    - Try to make Asteroids
    - A 2D maze game with enemies
        - Possibly log player records to SQL .db?
5.	Hardware-based application for which you program some device
    - Connecting to my heat pump output troubleshooting LEDs with an Arduino microcontroller

### 2. Research and Planning
Decided to go with idea number 4. This was to try and learn a new coding language while also implementing what was learned in SQL.

Learned about LOVE2d with Lua from a CS50 video. This was followed by going through the entire tutorial "How to LÖVE" by Sheepolution. These taught about game development in general and how to work with in the LÖVE2d framework in Lua using Visual Studio Code.  

Avoid Game Dev Landmines:

1. Don't skip prototyping
2. Don't over-scope
3. Don't focus on features over function

Main LOVE functions:
```lua
function love.load()
	"What to load at program start"
end

function love.update(dt) --dt to use for time adjusted for frame times
	"What to do every frame"
end

function love.draw()
	"Define what is seen on screen"
end
```
love.load -> love.update -> love.draw -> love.update -> love.draw -> love.update, etc.

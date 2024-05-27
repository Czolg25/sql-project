DROP PROCEDURE IF EXISTS DeleteUser;
DROP PROCEDURE IF EXISTS CheckComment;

DROP TRIGGER IF EXISTS AddCommentWarningOnInsertComment;
DROP TRIGGER IF EXISTS AddCommentWarningOnUpdateComment;
DROP TRIGGER IF EXISTS BackupUsersTrigger;

DROP TABLE IF EXISTS UsersBackups;
DROP TABLE IF EXISTS CommentWarnings;
DROP TABLE IF EXISTS Comments;
DROP TABLE IF EXISTS VideoCategories;
DROP TABLE IF EXISTS Categories;
DROP TABLE IF EXISTS Videos;
DROP TABLE IF EXISTS Subscriptions;
DROP TABLE IF EXISTS Users;


-- Tworzenie tabeli Users (Użytkownicy)
CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Username VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    Password VARBINARY(1000) NOT NULL,
    DateJoined DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE UNIQUE INDEX uniqueUsername ON Users (Username);
CREATE UNIQUE INDEX uniqueEmail ON Users (Email);

-- Tworzenie tabeli Videos (Filmy)
CREATE TABLE Videos (
    VideoID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT,
    Title VARCHAR(100) NOT NULL,
    Description VARCHAR(500),
    UploadDate DATETIME NOT NULL DEFAULT GETDATE(),
    Views INT DEFAULT 0,
    Likes INT DEFAULT 0,
    Dislikes INT DEFAULT 0,
    serverID INT,
    sectorID INT,
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);


CREATE INDEX indexTitle ON Videos (Title);
CREATE INDEX indexUploadDate ON Videos (UploadDate);

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id of storage server' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Videos', @level2type=N'COLUMN',@level2name=N'serverID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id of video address storage server' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Videos', @level2type=N'COLUMN',@level2name=N'sectorID';

-- Tworzenie tabeli Comments (Komentarze)
CREATE TABLE Comments (
    CommentID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT,
    VideoID INT,
    CommentText VARCHAR(500) NOT NULL,
    CommentDate DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (VideoID) REFERENCES Videos(VideoID)
);

-- Tworzenie tabeli Categories (Kategorie)
CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL
);
CREATE UNIQUE INDEX uniqueCategoryName ON Categories (CategoryName);

-- Tworzenie tabeli VideoCategories (Relacja wiele-do-wielu między Filmy a Kategorie)
CREATE TABLE VideoCategories (
    VideoID INT,
    CategoryID INT,
    PRIMARY KEY (VideoID, CategoryID),
    FOREIGN KEY (VideoID) REFERENCES Videos(VideoID),
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- Tworzenie tabeli Subscriptions (Subskrypcje użytkowników)
CREATE TABLE Subscriptions (
    SubscriberID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT,
    ChannelID INT,
    SubscriptionDate DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (ChannelID) REFERENCES Users(UserID)
);

CREATE INDEX indexUserID ON Subscriptions (UserID);
CREATE INDEX indexChannelID ON Subscriptions (ChannelID);

CREATE TABLE CommentWarnings (
    WarningID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT  NOT NULL,
    VideoID INT NOT NULL,
    CommentText VARCHAR(500) NOT NULL,
    WarningDate DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

CREATE INDEX userIDWarning ON CommentWarnings (UserID);
CREATE INDEX videoIDWarning ON CommentWarnings (VideoID);

CREATE TABLE UsersBackups (
    UserBackupID INT IDENTITY(1,1) PRIMARY KEY,
    Username VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    WarningCount INT NOT NULL,
    DateLeft DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE INDEX usernameBackups ON UsersBackups (Username,Email);


-- trigger and procedures 

CREATE PROCEDURE DeleteUser
    @UserID INT
AS
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY
        DELETE FROM CommentWarnings
        WHERE UserID = @UserID;

        DELETE FROM Comments
        WHERE UserID = @UserID;

        DELETE FROM Subscriptions
        WHERE UserID = @UserID OR ChannelID = @UserID;


        DELETE FROM Comments
        WHERE VideoID IN (SELECT VideoID FROM Videos WHERE UserID = @UserID);

        DELETE FROM VideoCategories
        WHERE VideoID IN (SELECT VideoID FROM Videos WHERE UserID = @UserID);

        DELETE FROM Videos
        WHERE UserID = @UserID;

        DELETE FROM Users
        WHERE UserID = @UserID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
       
        THROW;
    END CATCH
END;

CREATE PROCEDURE CheckComment
    @commentID INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
	DECLARE @BadWorlds TABLE ([World] VARCHAR(20));
	INSERT INTO @BadWorlds VALUES ('Example'),('Bad'),('world');

	DECLARE @Comment TABLE (
		UserID INT  NOT NULL,
		VideoID INT NOT NULL,
		CommentText VARCHAR(500) NOT NULL
	);

	INSERT INTO @Comment SELECT UserID,VideoID,CommentText FROM Comments WHERE commentID = @commentID;

			DECLARE @CommentText VARCHAR(500) = (SELECT CommentText FROM @Comment);
	SET @CommentText = LOWER(@CommentText);

	SET @CommentText = REPLACE(REPLACE(REPLACE(LOWER(@CommentText),'.',''),'!',''),',',''); -- example chars to delete

	DECLARE @Word VARCHAR(100);
	DECLARE @Pos INT;
	DECLARE @Len INT;

	SET @Pos = CHARINDEX(' ', @CommentText);
	SET @Len = LEN(@CommentText);

	WHILE @Len > 0
	BEGIN
		IF @Pos > 0
		BEGIN
			SET @Word = LEFT(@CommentText, @Pos - 1);

			IF EXISTS (SELECT 1 FROM @BadWorlds WHERE World LIKE @Word)
			BEGIN
				INSERT INTO CommentWarnings(UserID,VideoID,CommentText) VALUES ((SELECT UserID FROM @Comment),(SELECT VideoID FROM @Comment),@CommentText);
				COMMIT TRANSACTION;
				RETURN;
			END

			SET @CommentText = RIGHT(@CommentText, @Len - @Pos);

			SET @Pos = CHARINDEX(' ', @CommentText);
			SET @Len = LEN(@CommentText);
		END
		ELSE
			BEGIN
			
			SET @Word = @CommentText;

			IF EXISTS (SELECT 1 FROM @BadWorlds WHERE World LIKE @Word)
			BEGIN
				INSERT INTO CommentWarnings(UserID,VideoID,CommentText) VALUES ((SELECT UserID FROM @Comment),(SELECT VideoID FROM @Comment),@CommentText);
				COMMIT TRANSACTION;
				RETURN;
				END

			SET @Len = 0;
		END
	END

	COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
	   
		THROW;
	END CATCH
END;

CREATE TRIGGER AddCommentWarningOnInsertComment
ON Comments
FOR INSERT
AS
BEGIN
    DECLARE @CommentID INT;
    DECLARE CommentCursor CURSOR FOR (SELECT CommentID FROM inserted);
    
    OPEN CommentCursor;
    FETCH NEXT FROM CommentCursor INTO @CommentID;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC checkComment @commentID = @CommentID;
        FETCH NEXT FROM CommentCursor INTO @CommentID;
    END;
    
    CLOSE CommentCursor;
    DEALLOCATE CommentCursor;
END;

CREATE TRIGGER AddCommentWarningOnUpdateComment
ON Comments
FOR UPDATE
AS
BEGIN
    DECLARE @CommentID INT;
    DECLARE CommentCursor CURSOR FOR (SELECT CommentID FROM inserted);
    
    OPEN CommentCursor;
    FETCH NEXT FROM CommentCursor INTO @CommentID;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC checkComment @commentID = @CommentID;
        FETCH NEXT FROM CommentCursor INTO @CommentID;
    END;
    
    CLOSE CommentCursor;
    DEALLOCATE CommentCursor;
END;


CREATE TRIGGER BackupUsersTrigger
ON CommentWarnings
for DELETE
AS
BEGIN
    INSERT INTO UsersBackups(Username,Email,WarningCount) SELECT Users.Username,Users.Email, COUNT(Users.UserID) AS WarningCount FROM deleted
    INNER JOIN Users ON deleted.UserID = Users.UserID
    GROUP BY Users.UserID, Users.Username,Users.Email;
END;

-- data

-- Uzupełnienie tabeli Users (Użytkownicy)
INSERT INTO Users (Username, Email, Password, DateJoined) VALUES ('john_doe', 'john@example.com',HASHBYTES('SHA2_256','password123'), '2023-01-15');
INSERT INTO Users (Username, Email, Password, DateJoined) VALUES ('jane_smith', 'jane@example.com', HASHBYTES('SHA2_256','passw0rd'), '2023-02-20');
INSERT INTO Users (Username, Email, Password, DateJoined) VALUES ( 'mike_jones', 'mike@example.com', HASHBYTES('SHA2_256','securepass'), '2023-03-10');
INSERT INTO Users (Username, Email, Password, DateJoined) VALUES ( 'sarah_wilson', 'sarah@example.com', HASHBYTES('SHA2_256','sarahpass'), '2023-04-05');
INSERT INTO Users (Username, Email, Password) VALUES ( 'chris_brown','chris@example.com',  HASHBYTES('SHA2_256','brown123'));
INSERT INTO Users (Username, Email, Password) VALUES ( 'anna_s', 'as@ox.com', HASHBYTES('SHA2_256','psss'));
INSERT INTO Users (Username, Email, Password) VALUES ( 'test', 'tt@ox.com',  HASHBYTES('SHA2_256','qq'));
INSERT INTO Users (Username, Email, Password) VALUES ( 'test3', 'tat@ox.com',  HASHBYTES('SHA2_256','qq'));
INSERT INTO Users (Username, Email, Password) VALUES ( 'test2', 'tdt@ox.com',  HASHBYTES('SHA2_256','qq'));

-- Uzupełnienie tabeli Videos (Filmy)
INSERT INTO Videos (UserID, Title, Description, UploadDate, Views, Likes, Dislikes) VALUES (1, 'How to Cook Pasta', 'Learn the art of cooking pasta from scratch.', '2023-01-20', 5000, 100, 5);
INSERT INTO Videos (UserID, Title, Description, UploadDate, Views, Likes, Dislikes) VALUES (2, 'Guitar Tutorial: Beginner to Pro', 'Master the guitar with this comprehensive tutorial series.', '2023-02-25', 8000, 200, 8);
INSERT INTO Videos (UserID, Title, Description, UploadDate, Views, Likes, Dislikes) VALUES ( 1, 'Fitness Tips for Beginners', 'Get started on your fitness journey with these helpful tips.', '2023-03-15', 3000, 80, 2);
INSERT INTO Videos (UserID, Title, Description, UploadDate, Views, Likes, Dislikes) VALUES ( 3, 'Morning Yoga Routine', 'Start your day right with this energizing yoga routine.', '2023-04-10', 4500, 120, 3);
INSERT INTO Videos (UserID, Title, Description, UploadDate, Views, Likes, Dislikes) VALUES ( 4, 'DIY Home Decor Ideas', 'Spruce up your living space with these creative DIY decor ideas.', '2023-05-15', 6000, 150, 5);
INSERT INTO Videos (UserID, Title, Description, UploadDate, Views, Likes, Dislikes) VALUES ( 5, 'Photography Tips for Beginners', 'Learn the basics of photography and improve your skills.', '2023-06-20', 4000, 100, 2);

-- Uzupełnienie tabeli Comments (Komentarze)
INSERT INTO Comments ( UserID, VideoID, CommentText, CommentDate) VALUES ( 2, 1, 'Great recipe! Can''t wait to try it out.', '2023-01-21');
INSERT INTO Comments ( UserID, VideoID, CommentText, CommentDate) VALUES ( 3, 1, 'Thanks for sharing! Really helpful.', '2023-01-22');
INSERT INTO Comments ( UserID, VideoID, CommentText, CommentDate) VALUES ( 1, 2, 'Excellent tutorial! Learned a lot.', '2023-02-26');
INSERT INTO Comments ( UserID, VideoID, CommentText, CommentDate) VALUES ( 3, 3, 'Awesome tips! Just what I needed to get started.', '2023-03-16');
INSERT INTO Comments ( UserID, VideoID, CommentText, CommentDate) VALUES ( 4, 4, 'Fantastic routine! Feels amazing after doing it.', '2023-04-11');
INSERT INTO Comments ( UserID, VideoID, CommentText) VALUES ( 5, 4, 'Thank you for sharing! Great way to start the day.');
INSERT INTO Comments ( UserID, VideoID, CommentText, CommentDate) VALUES ( 1, 5, 'Love these ideas! Can''t wait to try them out.', '2023-05-16');
INSERT INTO Comments ( UserID, VideoID, CommentText, CommentDate) VALUES ( 2, 6, 'Very helpful tips! Excited to practice them.', '2023-06-21');
INSERT INTO Comments ( UserID, VideoID, CommentText, CommentDate) VALUES ( 8, 6, 'very bad video.', '2023-06-21');
INSERT INTO Comments ( UserID, VideoID, CommentText, CommentDate) VALUES ( 8, 6, 'bad video.', '2023-06-21');
INSERT INTO Comments ( UserID, VideoID, CommentText, CommentDate) VALUES ( 8, 6, 'bad video.', '2023-06-21');
INSERT INTO Comments ( UserID, VideoID, CommentText, CommentDate) VALUES ( 9, 6, 'very bad video.', '2023-06-21');


-- Uzupełnienie tabeli Categories (Kategorie)
INSERT INTO Categories ( CategoryName) VALUES ( 'Cooking');
INSERT INTO Categories ( CategoryName) VALUES ( 'Music');
INSERT INTO Categories ( CategoryName) VALUES ( 'Fitness');
INSERT INTO Categories ( CategoryName) VALUES ( 'Craft');


-- Uzupełnienie tabeli VideoCategories (Relacja wiele-do-wielu między Filmy a Kategorie)
INSERT INTO VideoCategories (VideoID, CategoryID) VALUES (1, 1);
INSERT INTO VideoCategories (VideoID, CategoryID) VALUES (2, 2);
INSERT INTO VideoCategories (VideoID, CategoryID) VALUES (3, 3);
INSERT INTO VideoCategories (VideoID, CategoryID) VALUES (4, 3);
INSERT INTO VideoCategories (VideoID, CategoryID) VALUES (5, 2);
INSERT INTO VideoCategories (VideoID, CategoryID) VALUES (6, 1);


-- Uzupełnienie tabeli Subscriptions (Subskrypcje użytkowników)
INSERT INTO Subscriptions (UserID, ChannelID) VALUES (2, 1);
INSERT INTO Subscriptions (UserID, ChannelID) VALUES (3, 2);
INSERT INTO Subscriptions (UserID, ChannelID) VALUES (1, 3);
INSERT INTO Subscriptions (UserID, ChannelID) VALUES ( 5, 4);
INSERT INTO Subscriptions (UserID, ChannelID) VALUES (1, 5);
INSERT INTO Subscriptions (UserID, ChannelID) VALUES (2, 3);

INSERT INTO Subscriptions (UserID, ChannelID) VALUES (1, 1);
INSERT INTO Subscriptions (UserID, ChannelID) VALUES (2, 2);
INSERT INTO Subscriptions (UserID, ChannelID) VALUES (3, 3);
INSERT INTO Subscriptions (UserID, ChannelID) VALUES ( 4, 4);
INSERT INTO Subscriptions (UserID, ChannelID) VALUES (2, 5);
INSERT INTO Subscriptions (UserID, ChannelID) VALUES (4, 3);


UPDATE Comments SET CommentText= 'Bad user and very bad video' WHERE CommentID = 12;
UPDATE Comments SET CommentText= 'Bad user and very bad video ' WHERE CommentID = 8;
UPDATE Comments SET CommentText= 'Bad user and very bad video :(' WHERE CommentID = 1;
EXEC DeleteUser @UserID = 8;
EXEC DeleteUser @UserID = 9;

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
    serverID INT NOT NULL,
    sectorID INT NOT NULL,
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);


CREATE INDEX indexTitle ON Videos (Title);
CREATE INDEX indexUploadDate ON Videos (UploadDate);
CREATE INDEX indexVideoStorage ON Videos (serverID,sectorID);

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
CREATE TABLE CommentWarnings (
    WarningID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT  NOT NULL,
    VideoID INT NOT NULL,
    CommentText VARCHAR(500) NOT NULL,
    WarningDate DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

CREATE INDEX userIDWarning ON CommentWarnings (UserID);

CREATE TABLE UsersBackups (
    UserBackupID INT IDENTITY(1,1) PRIMARY KEY,
    Username VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    WarningCount INT NOT NULL,
    DateLeft DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE INDEX indexUsernameBackups ON UsersBackups (Username,Email);

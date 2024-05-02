-- Tworzenie tabeli Users (Użytkownicy)
CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Username VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    Password VARCHAR(100) NOT NULL,
    DateJoined DATETIME NOT NULL DEFAULT GETDATE()
);

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
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- Tworzenie tabeli Comments (Komentarze)
CREATE TABLE Comments (
    CommentID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT,
    VideoID INT,
    CommentText VARCHAR(500) NOT NULL,
    CommentDate DATETIME NOT NULL,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (VideoID) REFERENCES Videos(VideoID)
);

-- Tworzenie tabeli Categories (Kategorie)
CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL
);

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

-- Uzupełnienie tabeli Users (Użytkownicy)
INSERT INTO Users (Username, Email, Password, DateJoined) VALUES ('john_doe', 'john@example.com', 'password123', '2023-01-15');
INSERT INTO Users (Username, Email, Password, DateJoined) VALUES ('jane_smith', 'jane@example.com', 'passw0rd', '2023-02-20');
INSERT INTO Users (Username, Email, Password, DateJoined) VALUES ( 'mike_jones', 'mike@example.com', 'securepass', '2023-03-10');
INSERT INTO Users (Username, Email, Password, DateJoined) VALUES ( 'sarah_wilson', 'sarah@example.com', 'sarahpass', '2023-04-05');
INSERT INTO Users (Username, Email, Password) VALUES ( 'chris_brown', 'chris@example.com', 'brown123');
INSERT INTO Users (Username, Email, Password) VALUES ( 'anna_s', 'as@ox.com', 'psss');
INSERT INTO Users (Username, Email, Password) VALUES ( 'test', 'tt@ox.com', 'qq');

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
INSERT INTO Comments ( UserID, VideoID, CommentText, CommentDate) VALUES ( 5, 4, 'Thank you for sharing! Great way to start the day.', '2023-04-12');
INSERT INTO Comments ( UserID, VideoID, CommentText, CommentDate) VALUES ( 1, 5, 'Love these ideas! Can''t wait to try them out.', '2023-05-16');
INSERT INTO Comments ( UserID, VideoID, CommentText, CommentDate) VALUES ( 2, 6, 'Very helpful tips! Excited to practice them.', '2023-06-21');


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

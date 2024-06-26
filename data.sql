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
INSERT INTO Videos (UserID, Title, Description, UploadDate, Views, Likes, Dislikes,serverID,sectorID) VALUES (1, 'How to Cook Pasta', 'Learn the art of cooking pasta from scratch.', '2023-01-20', 5000, 100, 5,1,1);
INSERT INTO Videos (UserID, Title, Description, UploadDate, Views, Likes, Dislikes,serverID,sectorID) VALUES (2, 'Guitar Tutorial: Beginner to Pro', 'Master the guitar with this comprehensive tutorial series.', '2023-02-25', 8000, 200, 8,1,2);
INSERT INTO Videos (UserID, Title, Description, UploadDate, Views, Likes, Dislikes,serverID,sectorID) VALUES ( 1, 'Fitness Tips for Beginners', 'Get started on your fitness journey with these helpful tips.', '2023-03-15', 3000, 80, 2,1,3);
INSERT INTO Videos (UserID, Title, Description, UploadDate, Views, Likes, Dislikes,serverID,sectorID) VALUES ( 3, 'Morning Yoga Routine', 'Start your day right with this energizing yoga routine.', '2023-04-10', 4500, 120, 3,3,2);
INSERT INTO Videos (UserID, Title, Description, UploadDate, Views, Likes, Dislikes,serverID,sectorID) VALUES ( 4, 'DIY Home Decor Ideas', 'Spruce up your living space with these creative DIY decor ideas.', '2023-05-15', 6000, 150, 5,5,4);
INSERT INTO Videos (UserID, Title, Description, UploadDate, Views, Likes, Dislikes,serverID,sectorID) VALUES ( 5, 'Photography Tips for Beginners', 'Learn the basics of photography and improve your skills.', '2023-06-20', 4000, 100, 2,6,7);

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

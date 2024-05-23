-- zad a
-- Sortowanie pod względem kto był 1 w serwisie
select Username from Users order by DateJoined;
-- Sortowanie pod względem nicku
select Username from Users order by Username;

--zad b
--sprawdzenie czy istnieje taki użytkownik oraz czy podał poprawne hasło
select Username from Users where Username like 'john_doe' and Password like pwdencrypt('password123');
--Wyświetla kategorie zaczynające się od C
select CategoryName from Categories where CategoryName like 'C%';

--zad c
--wyświetla Tytuły filmów które mają więcej niż 5000 wyświetleń
select Title from Videos where  Views > 5000;
--Nowi użytkownicy
select Username from Users where Cast(DateJoined as Date) = Cast(GETDATE() as Date);

--zad d
SELECT UserID, Username, Email, DateJoined FROM Users WHERE DateJoined >= DATEADD(DAY, -30, GETDATE());
WITH CommentDifferences AS (
    SELECT VideoID,
           DATEDIFF(DAY, LAG(CommentDate) OVER (PARTITION BY VideoID ORDER BY CommentDate), CommentDate) AS DaysBetweenComments
    FROM Comments
)
SELECT VideoID,
       AVG(CAST(DaysBetweenComments AS FLOAT)) AS AvgDaysBetweenComments
FROM CommentDifferences
GROUP BY VideoID;

--zad e
--kto ile ma subskrybcji
select Username,count(Subscriptions.UserID) as Subscription from Users inner join Subscriptions on Users.UserID = Subscriptions.ChannelID  group by Username;
--średnia ilość wyświetleń
select Users.Username,avg(Videos.Views) as AvgVievs from Users inner join Videos on Users.UserID = Videos.UserID  group by Users.Username;

--zad f
-- 3 joiny
select Users.Username as ChanelName,Users2.UserName as SubscriberName from Users inner join Subscriptions on Subscriptions.ChannelID =Users.UserID inner join Users as Users2 on Users2.UserID = Subscriptions.UserID ; 
--4 joiny
select * from Users inner join Videos on Users.UserID = Videos.UserID inner join VideoCategories on VideoCategories.VideoID = Videos.VideoID inner join Categories on Categories.CategoryID = VideoCategories.CategoryID;

--zad g
select *  from Users left join Subscriptions on Subscriptions.ChannelID =Users.UserID  ; 

--zad f
SELECT u.UserID, u.Username, u.Email, u.DateJoined, v.VideoCount
FROM Users u
JOIN (
    SELECT UserID, COUNT(VideoID) AS VideoCount
    FROM Videos
    GROUP BY UserID
    HAVING COUNT(VideoID) > (SELECT AVG(VideoCount) FROM (SELECT COUNT(VideoID) AS VideoCount FROM Videos GROUP BY UserID) AS SubQuery)
) v ON u.UserID = v.UserID;

SELECT v.VideoID, v.Title, v.Description, v.UploadDate, v.Views, v.Likes, v.Dislikes, c.CommentCount
FROM Videos v
JOIN (
    SELECT VideoID, COUNT(CommentID) AS CommentCount
    FROM Comments
    GROUP BY VideoID
    HAVING COUNT(CommentID) > (SELECT AVG(CommentCount) FROM (SELECT COUNT(CommentID) AS CommentCount FROM Comments GROUP BY VideoID) AS SubQuery)
) c ON v.VideoID = c.VideoID;
--dodatek
begin transaction;
EXEC deleteUser @UserID = 4;
select * from Users
rollback transaction;

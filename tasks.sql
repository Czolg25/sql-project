-- zad a
-- Sortowanie pod względem kto był 1 w serwisie
select Username from Users order by DateJoined;
-- Sortowanie pod względem nicku
select Username from Users order by Username;

--zad b
--sprawdzenie czy istnieje taki użytkownik oraz czy podał poprawne hasło
select Username from Users where Username like 'john_doe' and Password like 'password123';
--Wyświetla kategorie zaczynające się od C
select CategoryName from Categories where CategoryName like 'C%';

--zad c
--wyświetla Tytuły filmów które mają więcej niż 5000 wyświetleń
select Title from Videos where  Views > 5000;
--Nowi użytkownicy
select Username from Users where Cast(DateJoined as Date) = Cast(GETDATE() as Date);

--zad d

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

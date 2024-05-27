CREATE PROCEDURE deleteUser
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

CREATE PROCEDURE checkComment
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
print @CommentText;
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
TRIGGER

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


CREATE TRIGGER backupUsersTrigger
ON CommentWarnings
for DELETE
AS
BEGIN
    INSERT INTO UsersBackups(Username,Email,WarningCount) SELECT Users.Username,Users.Email, COUNT(Users.UserID) AS WarningCount FROM deleted
    INNER JOIN Users ON deleted.UserID = Users.UserID
    GROUP BY Users.UserID, Users.Username,Users.Email;
END;

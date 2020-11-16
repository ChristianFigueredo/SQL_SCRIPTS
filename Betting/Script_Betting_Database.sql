CREATE DATABASE Betting
GO

USE Betting;
GO

CREATE TABLE roulette (
	id INT IDENTITY(1,1) PRIMARY KEY,
	startDate DATETIME DEFAULT GETDATE(),
	endDate DATETIME,
	finalColor VARCHAR(40),
	finalnumber INT,
	status INT NOT NULL,
); 
GO

CREATE TABLE client (
	id INT IDENTITY(1,1) PRIMARY KEY,
	password VARCHAR(40),
	username VARCHAR(40),
	name VARCHAR(40),
	credit FLOAT NOT NULL,
	status BIT NOT NULL
);
GO

CREATE TABLE bet (
	id INT IDENTITY(1,1) PRIMARY KEY,
	color VARCHAR(40),
	number INT,
	mount FLOAT NOT NULL,
	rouletteId INT FOREIGN KEY REFERENCES roulette (id),
	clientId INT FOREIGN KEY REFERENCES client (id)
);
GO

CREATE TABLE access (
	id INT IDENTITY(1,1) PRIMARY KEY,
	status BIT DEFAULT 1,
	startDate DATETIME DEFAULT GETDATE(),
	endDate DATETIME,
	remark VARCHAR(20),
	clientId INT FOREIGN KEY REFERENCES client (id)
);
GO

CREATE PROCEDURE spCreateNewUser 
@password VARCHAR(40),
@username VARCHAR(40),
@name VARCHAR(40)
AS
	DECLARE @clientResult INT
	DECLARE @response INT
	SET @clientResult = (SELECT id FROM client WHERE username = @username)
	IF (@clientResult < 0 AND @clientResult IS NOT NULL)
	BEGIN
		SET @response = 0
	END
	ELSE
	BEGIN
		INSERT INTO client (password, username, name , status, credit) VALUES ( @password, @username, @name, 1, 0);
		SET @response = 1
	END

	SELECT @response AS result
GO

CREATE PROCEDURE getUserSessionId
@username VARCHAR(40),
@password VARCHAR(40)
AS
	DECLARE @clientResult INT
	DECLARE @accessResult INT
	DECLARE @result VARCHAR(40)
	SET @clientResult = (SELECT TOP 1 id FROM client WHERE username = @username AND password = @password AND status = 1)
	IF  (@clientResult > 0 AND @clientResult IS NOT NULL)
	BEGIN
		SET @accessResult = (SELECT id FROM access WHERE clientId = @clientResult AND status = 1)
		IF(@accessResult > 0 OR @accessResult IS NOT NULL)
		BEGIN
			SET @result = 0
		END
		ELSE
		BEGIN
			INSERT INTO access (clientId, remark) VALUES (@clientResult, 'VALID') 
			SET @result = SCOPE_IDENTITY()
		END
	END 
	ELSE
	BEGIN
		SET @result = 0
	END

	SELECT @result AS idSession
GO

CREATE PROCEDURE destroyUserSessions
AS
	UPDATE access SET status = 0, remark = 'Session Expired' WHERE id in (SELECT id from access where status = 1 AND startDate < DATEADD(HOUR, -1 , GETDATE()))
GO

CREATE PROCEDURE createNewRoulette
AS
	DECLARE @id INT
	INSERT INTO roulette (status, endDate, finalColor, finalnumber) VALUES (0, CONVERT( datetime, '1900-01-01T00:00:00.000'), '', 0)
	SET @id = SCOPE_IDENTITY()
	SELECT @id AS rouletteId
GO

CREATE PROCEDURE openRoulette
@id INT
AS
	UPDATE roulette SET status = 1 WHERE id  = @id and status = 0
	SELECT @@ROWCOUNT AS affectedRows
GO

CREATE PROCEDURE closeRoulette
@rouletteId INT,
@number INT,
@color  VARCHAR(40)
AS
	DECLARE @tempTable TABLE (client VARCHAR(40), betType VARCHAR(10), amount FLOAT, number INT, color VARCHAR(10), pay FLOAT, clientId INT, result VARCHAR(30))
	DECLARE @tempTable2 TABLE (client VARCHAR(40), betType VARCHAR(10), amount FLOAT, number INT, color VARCHAR(10), pay FLOAT, clientId INT, result VARCHAR(30))
	DECLARE @count INT
	DECLARE @rId INT = 0
	SET @rId = (SELECT id FROM roulette WHERE id = @rouletteId AND status = 1)
	IF (@rId <> 0)
	BEGIN
		UPDATE roulette SET status = 2, finalColor = @color, finalnumber = @number, endDate = GETDATE() WHERE id = @rouletteId and status = 1
	
		INSERT INTO @tempTable
		SELECT C.name as client, 'COLOR' as betType, B.mount as amount, B.number as number, B.color as color, (B.mount * 1.8) as pay, C.id as clientId, 'GANADOR por color' as result
		from bet B INNER JOIN client C  on B.clientId = C.id where rouletteId = @rouletteId and color = @color
		UNION
		SELECT C.name as client, 'NUMBER' as betType, B.mount as amount, B.number as number, B.color as color, (B.mount * 5) as pay, C.id as clientId, 'GANADOR por numero' as result
		from bet B INNER JOIN client C on B.clientId = C.id where rouletteId = @rouletteId and number = @number

		INSERT INTO @tempTable2 
		SELECT * FROM @tempTable

		INSERT INTO @tempTable2
		SELECT C.name as client, 'COLOR' as betType, B.mount as amount, B.number as number, B.color as color,  0 as pay, C.id as clientId, 'PERDEDOR por color' as result
		from bet B INNER JOIN client C  on B.clientId = C.id where rouletteId = @rouletteId and color <> @color
		UNION
		SELECT C.name as client, 'NUMBER' as betType, B.mount as amount, B.number as number, B.color as color,  0 as pay, C.id as clientId, 'PERDEDOR por numero' as result
		from bet B INNER JOIN client C on B.clientId = C.id where rouletteId = @rouletteId and number <> @number

		SELECT @count = COUNT(*) FROM @tempTable;
		WHILE @count > 0
		BEGIN
			update client set credit = (credit + (SELECT TOP(1) pay FROM @tempTable)) WHERE id = (SELECT TOP(1) clientId FROM @tempTable)
			DELETE TOP (1) FROM @tempTable
			SELECT @count = COUNT(*) FROM @tempTable;
		END
	END
	ELSE
	BEGIN
		INSERT INTO @tempTable2 (client, betType, amount, number, color, pay, clientId, result) VALUES ('','', 0,0,'',0,0,'0')
	END
	SELECT * from  @tempTable2
GO

CREATE VIEW getRouletteStatus
AS
	SELECT * FROM roulette where status in (1,2)
GO

CREATE PROCEDURE betTransacction
@tokenDecoded INT,
@betNumber INT,
@betColor VARCHAR(40),
@mount FLOAT,
@rouletteId INT
AS
	DECLARE @availableCredit FLOAT
	DECLARE @statusRoulette INT
	DECLARE @clientId INT
	DECLARE @statusResult INT = 1
	DECLARE @messageResult VARCHAR(200)
	DECLARE @betId INT = 0
	SET @clientId = (SELECT clientId FROM access WHERE id = @tokenDecoded and status = 1)
	SET @statusRoulette = (SELECT status FROM roulette WHERE id = @rouletteId and status = 1)
	SET @availableCredit = (SELECT credit FROM client WHERE id = @clientId)
	IF(@clientId > 0)
	BEGIN
		IF(@availableCredit < @mount)
		BEGIN
			SET @messageResult = CONCAT(@messageResult  ,'Credito insuficiente. ')
			SET @statusResult = 0
		END
	END
	ELSE
	BEGIN 
		SET @messageResult = CONCAT(@messageResult  ,'El token es invalido. ')
		SET @statusResult = 0
	END
	IF(@statusRoulette <> 1 OR @statusRoulette IS NULL)
	BEGIN
		SET @messageResult = CONCAT(@messageResult  ,'Ruleta no encontrada. ')
		SET @statusResult = 0
	END
	IF(@betNumber < 0 OR @betNumber > 36)
	BEGIN
		SET @messageResult = CONCAT(@messageResult  ,'El numero de apuesta debe estar entre 0 y 36. ')
		SET @statusResult = 0
	END
	IF(@mount < 1 OR @mount > 10000)
	BEGIN
		SET @messageResult = CONCAT(@messageResult  ,'El monto de la apuesta debe estar entre $1 y $10000. ')
		SET @statusResult = 0
	END
	IF((@betColor = 'NEGRO' AND (@betNumber % 2 = 0)) OR (@betColor = 'ROJO' AND (@betNumber % 2 <> 0)))
	BEGIN
		SET @messageResult = CONCAT(@messageResult  ,'Los rojos debe ser par y los negros impar. ')
		SET @statusResult = 0
	END
	IF(@statusResult = 1)
	BEGIN
		INSERT INTO bet (clientId, number, color, mount, rouletteId) VALUES (@clientId, @betNumber, @betColor, @mount, @rouletteId)
		update client set credit = (credit - @mount) where id = @clientId
		SET @betId = (SELECT SCOPE_IDENTITY())
		SET @messageResult = CONCAT(@messageResult  ,'Su apuesta se registro en el sistema.')
	END
		
	SELECT @statusResult as statusResult, @messageResult as messageResult, @betId as betId
GO

CREATE PROCEDURE reloadClientCredits
@amount FLOAT,
@clientId INT
AS
	DECLARE @clientResult INT
	DECLARE @result VARCHAR(40)
	SET @clientResult = (SELECT TOP 1 id FROM client WHERE id = @clientId)
	IF  (@clientResult > 0 AND @clientResult IS NOT NULL)
	BEGIN
		update client set credit = (credit + @amount) where id = @clientId
		SET @result = 1
	END 
	ELSE
	BEGIN
		SET @result = 0
	END

	SELECT @result AS idSession
GO








USE TravelAgency

-----------------------------------Task 1-----------------------------------
--CREATE TRIGGER LogonTrigger
--ON ALL SERVER
--FOR LOGON
--AS
--BEGIN
--    PRINT 'Добро пожаловать, ' + ORIGINAL_LOGIN() + '!'
--END;

--DISABLE TRIGGER LogonTrigger ON ALL SERVER;
--ENABLE TRIGGER LogonTrigger ON ALL SERVER;
--DROP TRIGGER LogonTrigger ON ALL SERVER; --проблема была в отсутсвии ON ALL SERVER потому что триггер серверный
-----------------------------------Task 2-----------------------------------
--CREATE TABLE DDLLog (
--    LogID INT IDENTITY(1,1) PRIMARY KEY,
--    EventType NVARCHAR(100),
--    ObjectName NVARCHAR(255),
--    ObjectType NVARCHAR(100),
--    EventData XML,
--    EventDate DATETIME DEFAULT GETDATE()
--);

--CREATE TRIGGER LogDDLOperations
--ON DATABASE
--FOR CREATE_TABLE, ALTER_TABLE, DROP_TABLE, CREATE_TRIGGER, ALTER_TRIGGER, DROP_TRIGGER
--AS
--BEGIN
--    SET NOCOUNT ON;

--    DECLARE @EventData XML = EVENTDATA();

--    INSERT INTO DDLLog (EventType, ObjectName, ObjectType, EventData, EventDate)
--    VALUES (
--        @EventData.value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(100)'),
--        @EventData.value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(255)'),
--        @EventData.value('(/EVENT_INSTANCE/ObjectType)[1]', 'NVARCHAR(100)'),
--        @EventData,
--        GETDATE()
--    );
--END;
---------Task 2 TEST-------
--CREATE TABLE TestTable (
--    ID INT PRIMARY KEY,
--    Name NVARCHAR(100)
--);

--ALTER TABLE TestTable
--ADD Age INT;

--DROP TABLE TestTable;
 
--SELECT * FROM DDLLog;
-------Task 2 TEST-------
-----------------------------------Task 3-----------------------------------
 GO
-- Копия таблицы tbl_Client
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE ID=OBJECT_ID('tbl_Client_Copy')) DROP TABLE tbl_Client_Copy
GO
CREATE TABLE tbl_Client_Copy (
  IDClient INT IDENTITY(1,1) NOT NULL,
  PhoneNumber INT NOT NULL,
  ApartmanetNumber INT NOT NULL,
  BuildingNumber INT NOT NULL,
  FullName VARCHAR(50) NOT NULL,
  IDStreet INT NOT NULL,
  CONSTRAINT CS_IDClient_Copy_PK PRIMARY KEY(IDClient),
  CONSTRAINT CS_IDStreet_Copy_FK FOREIGN KEY(IDStreet) REFERENCES tbl_Street(IDStreet) ON DELETE CASCADE ON UPDATE CASCADE
);
ALTER TABLE tbl_Client_Copy WITH NOCHECK
ADD CHECK (ApartmanetNumber > 0),
    CHECK (BuildingNumber > 0);
GO

-- Копия таблицы tbl_Trip
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE ID=OBJECT_ID('tbl_Trip_Copy')) DROP TABLE tbl_Trip_Copy
GO
CREATE TABLE tbl_Trip_Copy (
  IDTrip INT NOT NULL IDENTITY(1,1),
  TripCost INT NOT NULL,
  TripDuration INT NOT NULL,
  DepartureDate DATE NOT NULL,
  IDRoute INT NOT NULL,
  IDClient INT NOT NULL,
  CONSTRAINT CS_IDTrip_Copy_PK PRIMARY KEY(IDTrip),
  CONSTRAINT CS_Route_Copy_FK FOREIGN KEY(IDRoute) REFERENCES tbl_Route(IDRoute), 
  CONSTRAINT CS_IDClient_Copy_FK FOREIGN KEY(IDClient) REFERENCES tbl_Client_Copy(IDClient) ON DELETE CASCADE ON UPDATE CASCADE
);
ALTER TABLE tbl_Trip_Copy WITH NOCHECK
ADD CHECK (TripCost > 0),
    CHECK (TripDuration > 0);
GO


GO
-- Таблица-лог для tbl_Client_Copy
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE ID=OBJECT_ID('tbl_Client_Log')) DROP TABLE tbl_Client_Log
GO
CREATE TABLE tbl_Client_Log (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    IDClient INT,
    OperationType VARCHAR(10),
    ChangeDate DATETIME DEFAULT GETDATE(),
    PhoneNumber INT,
    ApartmanetNumber INT,
    BuildingNumber INT,
    FullName VARCHAR(50),
    IDStreet INT
);
GO

-- Таблица-лог для tbl_Trip_Copy
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE ID=OBJECT_ID('tbl_Trip_Log')) DROP TABLE tbl_Trip_Log
GO
CREATE TABLE tbl_Trip_Log (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    IDTrip INT,
    OperationType VARCHAR(10),
    ChangeDate DATETIME DEFAULT GETDATE(),
    TripCost INT,
    TripDuration INT,
    DepartureDate DATE,
    IDRoute INT,
    IDClient INT
);
GO
----
GO
-- Триггер для INSERT, UPDATE и DELETE на tbl_Client_Copy
CREATE TRIGGER trg_Client_Log
ON tbl_Client_Copy
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- INSERT логирование
    INSERT INTO tbl_Client_Log (IDClient, OperationType, PhoneNumber, ApartmanetNumber, BuildingNumber, FullName, IDStreet)
    SELECT IDClient, 'INSERT', PhoneNumber, ApartmanetNumber, BuildingNumber, FullName, IDStreet FROM INSERTED;

    -- UPDATE логирование
    INSERT INTO tbl_Client_Log (IDClient, OperationType, PhoneNumber, ApartmanetNumber, BuildingNumber, FullName, IDStreet)
    SELECT IDClient, 'UPDATE', PhoneNumber, ApartmanetNumber, BuildingNumber, FullName, IDStreet FROM INSERTED;

    -- DELETE логирование
    INSERT INTO tbl_Client_Log (IDClient, OperationType, PhoneNumber, ApartmanetNumber, BuildingNumber, FullName, IDStreet)
    SELECT IDClient, 'DELETE', PhoneNumber, ApartmanetNumber, BuildingNumber, FullName, IDStreet FROM DELETED;
END;
GO

-- Триггер для INSERT, UPDATE и DELETE на tbl_Trip_Copy
CREATE TRIGGER trg_Trip_Log
ON tbl_Trip_Copy
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- INSERT логирование
    INSERT INTO tbl_Trip_Log (IDTrip, OperationType, TripCost, TripDuration, DepartureDate, IDRoute, IDClient)
    SELECT IDTrip, 'INSERT', TripCost, TripDuration, DepartureDate, IDRoute, IDClient FROM INSERTED;

    -- UPDATE логирование
    INSERT INTO tbl_Trip_Log (IDTrip, OperationType, TripCost, TripDuration, DepartureDate, IDRoute, IDClient)
    SELECT IDTrip, 'UPDATE', TripCost, TripDuration, DepartureDate, IDRoute, IDClient FROM INSERTED;

    -- DELETE логирование
    INSERT INTO tbl_Trip_Log (IDTrip, OperationType, TripCost, TripDuration, DepartureDate, IDRoute, IDClient)
    SELECT IDTrip, 'DELETE', TripCost, TripDuration, DepartureDate, IDRoute, IDClient FROM DELETED;
END;
GO

-- Заполнение копии таблицы tbl_Client_Copy
INSERT INTO tbl_Client_Copy (PhoneNumber, ApartmanetNumber, BuildingNumber, FullName, IDStreet)
SELECT PhoneNumber, ApartmanetNumber, BuildingNumber, FullName, IDStreet FROM tbl_Client;
GO

-- Заполнение копии таблицы tbl_Trip_Copy
INSERT INTO tbl_Trip_Copy (TripCost, TripDuration, DepartureDate, IDRoute, IDClient)
SELECT TripCost, TripDuration, DepartureDate, IDRoute, IDClient FROM tbl_Trip;
GO

-----------------------------------Task 4-----------------------------------
GO
-- Триггер для запрета обновлений и удалений в tbl_Client_Log
CREATE TRIGGER trg_Client_Log_PreventChanges
ON tbl_Client_Log
INSTEAD OF DELETE, UPDATE
AS
BEGIN
    RAISERROR ('Операции обновления и удаления запрещены в таблице логов tbl_Client_Log.', 16, 1);
END;
GO

-- Триггер для запрета обновлений и удалений в tbl_Trip_Log
CREATE TRIGGER trg_Trip_Log_PreventChanges
ON tbl_Trip_Log
INSTEAD OF DELETE, UPDATE
AS
BEGIN
    RAISERROR ('Операции обновления и удаления запрещены в таблице логов tbl_Trip_Log.', 16, 1);
END;
GO


-- Попытка обновления в таблице Rashod_Log
UPDATE tbl_Client_Log
SET FullName = 'nobody'
WHERE IDClient = 5;
GO


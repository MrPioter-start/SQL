USE master

GO 
DROP DATABASE IF EXISTS TravelAgency
CREATE DATABASE TravelAgency
GO

USE TravelAgency

GO
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE ID=OBJECT_ID ('tbl_Street')) DROP TABLE tbl_Street
GO
CREATE TABLE tbl_Street(
  IDStreet INT IDENTITY(1,1) NOT NULL,
  StreetName VARCHAR(50) NOT NULL,
)
ALTER TABLE tbl_Street WITH NOCHECK
ADD CONSTRAINT CS_IDStreet_PK PRIMARY KEY(IDStreet);


GO
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE ID=OBJECT_ID('tbl_Client')) DROP TABLE tbl_Client
GO
CREATE TABLE tbl_Client(
  IDClient INT IDENTITY(1,1) NOT NULL,
  PhoneNumber INT NOT NULL,
  ApartmanetNumber INT NOT NULL,
  BuildingNumber INT NOT NULL,
  FullName VARCHAR(50) NOT NULL,
  IDStreet INT NOT NULL,

)
ALTER TABLE tbl_Client WITH NOCHECK
ADD CHECK (ApartmanetNumber > 0),
	CHECK (BuildingNumber > 0),
	CONSTRAINT CS_IDClient_PK PRIMARY KEY(IDClient),
	CONSTRAINT CS_IDStreet_FK FOREIGN KEY(IDStreet) REFERENCES tbl_Street(IDStreet) ON DELETE CASCADE ON UPDATE CASCADE;

GO
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE ID=OBJECT_ID('tbl_Hotel')) DROP TABLE tbl_Hotel
GO
CREATE TABLE tbl_Hotel(
  IDHotel INT NOT NULL IDENTITY(1,1),
  HotelStars INT NOT NULL,
  HotelName VARCHAR(50) NOT NULL,
)
ALTER TABLE tbl_Hotel WITH NOCHECK
ADD CHECK (HotelStars > 0),
	CONSTRAINT CS_IDHotel_PK PRIMARY KEY(IDHotel);


GO
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE ID=OBJECT_ID('tbl_Country')) DROP TABLE tbl_Country
GO
CREATE TABLE tbl_Country(
  IDCountry INT NOT NULL IDENTITY(1,1),
  CountryName VARCHAR(50) NOT NULL,
  Climate VARCHAR(20) NOT NULL,

)
ALTER TABLE tbl_Country WITH NOCHECK
ADD CONSTRAINT CS_IDCountry_PK PRIMARY KEY(IDCountry);


GO
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE ID=OBJECT_ID('tbl_Route')) DROP TABLE tbl_Route
GO
CREATE TABLE tbl_Route(
  IDRoute INT NOT NULL IDENTITY(1,1),
  RouteName VARCHAR(50) NOT NULL,
  IDCountry INT NOT NULL,
)
ALTER TABLE tbl_Route WITH NOCHECK
ADD CONSTRAINT CS_IDRoute_PK PRIMARY KEY(IDRoute),
	CONSTRAINT CS_IDCountry_FK FOREIGN KEY(IDCountry) REFERENCES tbl_Country(IDCountry)

GO
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE ID=OBJECT_ID('tbl_Triop')) DROP TABLE tbl_Trip
GO
CREATE TABLE tbl_Trip(
  IDTrip INT NOT NULL IDENTITY(1,1),
  TripCost INT NOT NULL,
  TripDuration INT NOT NULL,
  DepartureDate DATE NOT NULL,
  IDRoute INT NOT NULL,
  IDClient INT NOT NULL,
)
ALTER TABLE tbl_Trip WITH NOCHECK
ADD CHECK (TripCost > 0),
	CHECK (TripDuration > 0),
	CONSTRAINT CS_IDTrip_PK PRIMARY KEY(IDTrip),
	CONSTRAINT CS_Route_FK FOREIGN KEY(IDRoute) REFERENCES tbl_Route(IDRoute), 
	CONSTRAINT CS_IDClient_FK FOREIGN KEY(IDClient) REFERENCES tbl_Client(IDClient) ON DELETE CASCADE ON UPDATE CASCADE;

GO
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE ID=OBJECT_ID('tbl_Hotel_Route')) DROP TABLE tbl_Hotel_Route
GO
CREATE TABLE tbl_Hotel_Route(
	IDHotel INT NOT NULL,
	IDRoute INT NOT NULL
)
ALTER TABLE tbl_Hotel_Route WITH NOCHECK
ADD CONSTRAINT CS_IDRoute_FK FOREIGN KEY(IDRoute) REFERENCES tbl_Route(IDRoute),
	CONSTRAINT CS_IDHotel_FK FOREIGN KEY(IDHotel) REFERENCES tbl_Hotel(IDHotel)  

insert into tbl_Street([StreetName])
values  ('Леонида Беды'),
		('Волочаевская'),
		('Кольцова'),
		('Ольшевского'),
		('Коммунистическая')

insert into tbl_Client([PhoneNumber],[ApartmanetNumber],[BuildingNumber],[FullName], [IDStreet])	
values  (6066161, 1, 33, 'Метто Артемий Дмитриевич', (select IDStreet from tbl_Street where tbl_Street.StreetName like 'Ле%')),
		(5630333, 10, 20, 'Ануфриев Петр Владимирович', (select IDStreet from tbl_Street where tbl_Street.StreetName like 'Во%')),
		(7171717, 21, 3, 'Целых Евгений Алексеевич', (select IDStreet from tbl_Street where tbl_Street.StreetName like 'Кол%')),
		(7101771, 95, 15, 'Фецкович Артемий Сергеевич', (select IDStreet from tbl_Street where tbl_Street.StreetName like 'Ол%')),
		(6638285, 55, 56, 'Позняк Михаил Анатольевич', (select IDStreet from tbl_Street where tbl_Street.StreetName like 'Ком%'))


insert into tbl_Hotel([HotelName], [HotelStars])
values  ('Золотой пляж', 4),
		('Лунная роща', 5),
		('Солнечный берег', 3),
		('Коралловый залив', 4),
		('Горный хребет', 5)


insert into tbl_Country([CountryName], [Climate])
values	('Испания', 'Средиземноморский'),
		('Швеция', 'Умеренный'),
		('Таиланд', 'Тропический'),
		('Австралия', 'Переменный'),   
		('Япония', 'Умеренный')


insert into tbl_Route([RouteName], [IDCountry])
values  ('Париж-Лондон', (select IDCountry from tbl_Country where tbl_Country.CountryName like 'Ис%')),
		('Рим-Афины', (select IDCountry from tbl_Country where tbl_Country.CountryName like 'Шв%')),
		('Москва-Санкт-Петербург', (select IDCountry from tbl_Country where tbl_Country.CountryName like 'Та%')),
		('Нью-Йорк-Лос-Анджелес', (select IDCountry from tbl_Country where tbl_Country.CountryName like 'Ав%')),
		('Токио-Сеул', (select IDCountry from tbl_Country where tbl_Country.CountryName like 'Яп%'))

insert into tbl_Trip([TripCost], [TripDuration], [DepartureDate], [IDClient], [IDRoute])
values  (500, 7, '2024-06-15', (select IDClient from tbl_Client where tbl_Client.FullName like 'Ме%'), (select IDRoute from tbl_Route where tbl_Route.RouteName like 'Па%')),
		(800, 10, '2024-07-20', (select IDClient from tbl_Client where tbl_Client.FullName like 'Ан%'), (select IDRoute from tbl_Route where tbl_Route.RouteName like 'Ри%')),
		(600, 5, '2024-08-10', (select IDClient from tbl_Client where tbl_Client.FullName like 'Це%'), (select IDRoute from tbl_Route where tbl_Route.RouteName like 'Мо%')),
		(900, 14, '2024-09-05', (select IDClient from tbl_Client where tbl_Client.FullName like 'Фе%'), (select IDRoute from tbl_Route where tbl_Route.RouteName like 'Нь%')),
		(700, 8, '2024-10-02', (select IDClient from tbl_Client where tbl_Client.FullName like 'По%'), (select IDRoute from tbl_Route where tbl_Route.RouteName like 'То%'))


--delete tbl_Client where PhoneNumber = 5630333
--update tbl_Hotel set HotelStars = 1 where HotelStars = 4

--select * from tbl_Client
--select * from tbl_Hotel
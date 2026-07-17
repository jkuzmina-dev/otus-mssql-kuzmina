-- Exported from QuickDBD: https://www.quickdatabasediagrams.com/
-- NOTE! If you have used non-SQL datatypes in your design, you will have to change these here.

-- Modify this code to update the DB schema diagram.
-- To reset the sample schema, replace everything with
-- two dots ('..' - without quotes).
ALTER DATABASE Kindergarten SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
DROP DATABASE Kindergarten
GO

CREATE DATABASE Kindergarten
GO

USE Kindergarten
GO

SET XACT_ABORT ON

BEGIN TRANSACTION QUICKDBD

-- Дети
CREATE TABLE [Children] (
    [ChildID] int NOT NULL identity(1,1) ,
    [Name] NVARCHAR(255)  NOT NULL ,
    [Birthday] date  NOT NULL ,
    [Address] NVARCHAR(255)  NOT NULL ,
    [MotherID] int  NOT NULL ,
    [FatherID] int  NOT NULL ,
    CONSTRAINT [PK_Children] PRIMARY KEY CLUSTERED (
        [ChildID] ASC
    )
)

-- Взрослые (родители, воспитатели)
CREATE TABLE [Adults] (
    [AdultID] int NOT NULL identity(1,1) ,
    [Name] NVARCHAR(255)  NOT NULL ,
    [Birthday] date  NOT NULL ,
    [Address] NVARCHAR(255)  NOT NULL ,
    [Phone] NVARCHAR(100)  NOT NULL ,
    [Email] NVARCHAR(100)  NULL ,
    [Job] NVARCHAR(100)  NOT NULL ,
    [Education] NVARCHAR(255)  NOT NULL ,
    -- 1, если воспитатель
    [IsKindergartenTeacher] bit  NOT NULL ,
    CONSTRAINT [PK_Adults] PRIMARY KEY CLUSTERED (
        [AdultID] ASC
    )
)

-- Группы
CREATE TABLE [Groups] (
    [GroupID] int  NOT NULL identity(1,1) ,
    [Name] NVARCHAR(100)  NOT NULL ,
    -- ясли, младшая, средняя, старшая, подготовительная
    [Age] NVARCHAR(30)  NOT NULL ,
    -- 1 - ясли, 0 - все остальные
    [IsNursery] bit  NOT NULL ,
    CONSTRAINT [PK_Groups] PRIMARY KEY CLUSTERED (
        [GroupID] ASC
    )
)

-- Состав групп
CREATE TABLE [b_Children_Groups] (
    [b_Children_GroupsID] int  NOT NULL identity(1,1) PRIMARY KEY,
    [ChildID] int  NOT NULL ,
    [GroupID] int  NOT NULL ,
    [StartTime] DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL,
    [EndTime] DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL,
    PERIOD FOR SYSTEM_TIME (StartTime, EndTime)
)
WITH (SYSTEM_VERSIONING = ON);

-- Воспитатели в группах
CREATE TABLE [b_Adults_Groups] (
    [b_Adults_GroupsID] int  NOT NULL identity(1,1) PRIMARY KEY,
    [AdultID] int  NOT NULL ,
    [GroupID] int  NOT NULL ,
    [StartTime] DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL,
    [EndTime] DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL,
    PERIOD FOR SYSTEM_TIME (StartTime, EndTime)
)
WITH (SYSTEM_VERSIONING = ON);

-- Блюда в меню
CREATE TABLE [Food] (
    [FoodID] int  NOT NULL identity(1,1) ,
    [Name] NVARCHAR(100)  NOT NULL ,
    [ServingSizeNursery] int  NOT NULL ,
    [ServingSizeKindergarten] int  NOT NULL ,
    [Calories] int  NOT NULL ,
    CONSTRAINT [PK_Food] PRIMARY KEY CLUSTERED (
        [FoodID] ASC
    )
)

-- Меню на каждый день
CREATE TABLE [Menu] (
    [Date] date  NOT NULL ,
    -- завтрак, обед, полдник, ужин
    [MealTime] NVARCHAR(20)  NOT NULL ,
    [FoodID] int  NOT NULL ,
    [ServingSizeNursery] int  NOT NULL ,
    [ServingSizeKindergarten] int  NOT NULL ,
    [CaloriesNursery] int  NOT NULL ,
    [CaloriesKindergarten] int  NOT NULL 
)

-- Табель посещений
CREATE TABLE [Attendance] (
    [Date] date  NOT NULL ,
    [GroupID] int  NOT NULL ,
    [ChildID] int  NOT NULL 
)

-- Начисления и оплаты за д/с
CREATE TABLE [Operations] (
    [OperationID] int  NOT NULL identity(1,1) ,
    [ChildID] int  NOT NULL ,
    [Date] date  NOT NULL ,
    [Amount] decimal  NOT NULL ,
    -- начисление или погашение
    [OperationType] NVARCHAR(20)  NOT NULL ,
    CONSTRAINT [PK_Operations] PRIMARY KEY CLUSTERED (
        [OperationID] ASC
    )
)

ALTER TABLE [Children] WITH CHECK ADD CONSTRAINT [FK_Children_MotherID] FOREIGN KEY([MotherID])
REFERENCES [Adults] ([AdultID])

ALTER TABLE [Children] CHECK CONSTRAINT [FK_Children_MotherID]

ALTER TABLE [Children] WITH CHECK ADD CONSTRAINT [FK_Children_FatherID] FOREIGN KEY([FatherID])
REFERENCES [Adults] ([AdultID])

ALTER TABLE [Children] CHECK CONSTRAINT [FK_Children_FatherID]

---- Ограничение по возрасту - зачислять можно детей с 2 до 6 лет 
ALTER TABLE [Children]  
	ADD CONSTRAINT constr_birthday 
		CHECK ((datediff(yy, Birthday, getdate()) >= 2) AND (datediff(yy, Birthday, getdate()) <= 6));

ALTER TABLE [Adults] ADD  CONSTRAINT constr_kindergartenTeacher DEFAULT (0) FOR IsKindergartenTeacher;

ALTER TABLE [Groups] ADD UNIQUE (Name)

ALTER TABLE [Groups] ADD  CONSTRAINT constr_nursery DEFAULT (0) FOR IsNursery;

ALTER TABLE [Groups]  
	ADD CONSTRAINT constr_age 
		CHECK (Age in ('ясли', 'младшая', 'средняя', 'старшая', 'подготовительная'));

ALTER TABLE [b_Children_Groups] WITH CHECK ADD CONSTRAINT [FK_b_Children_Groups_ChildID] FOREIGN KEY([ChildID])
REFERENCES [Children] ([ChildID])

ALTER TABLE [b_Children_Groups] CHECK CONSTRAINT [FK_b_Children_Groups_ChildID]

ALTER TABLE [b_Children_Groups] WITH CHECK ADD CONSTRAINT [FK_b_Children_Groups_GroupID] FOREIGN KEY([GroupID])
REFERENCES [Groups] ([GroupID])

ALTER TABLE [b_Children_Groups] CHECK CONSTRAINT [FK_b_Children_Groups_GroupID]

ALTER TABLE [b_Adults_Groups] WITH CHECK ADD CONSTRAINT [FK_b_Adults_Groups_AdultID] FOREIGN KEY([AdultID])
REFERENCES [Adults] ([AdultID])

ALTER TABLE [b_Adults_Groups] CHECK CONSTRAINT [FK_b_Adults_Groups_AdultID]

ALTER TABLE [b_Adults_Groups] WITH CHECK ADD CONSTRAINT [FK_b_Adults_Groups_GroupID] FOREIGN KEY([GroupID])
REFERENCES [Groups] ([GroupID])

ALTER TABLE [b_Adults_Groups] CHECK CONSTRAINT [FK_b_Adults_Groups_GroupID]

ALTER TABLE [Food] ADD UNIQUE (Name)

ALTER TABLE [Menu] WITH CHECK ADD CONSTRAINT [FK_Menu_FoodID] FOREIGN KEY([FoodID])
REFERENCES [Food] ([FoodID])

ALTER TABLE [Menu] CHECK CONSTRAINT [FK_Menu_FoodID]

ALTER TABLE [Menu] 
ADD CONSTRAINT constr_mealTime 
		CHECK (MealTime in ('завтрак', 'обед', 'полдник', 'ужин'));

ALTER TABLE [Attendance] WITH CHECK ADD CONSTRAINT [FK_Attendance_GroupID] FOREIGN KEY([GroupID])
REFERENCES [Groups] ([GroupID])

ALTER TABLE [Attendance] CHECK CONSTRAINT [FK_Attendance_GroupID]

ALTER TABLE [Attendance] WITH CHECK ADD CONSTRAINT [FK_Attendance_ChildID] FOREIGN KEY([ChildID])
REFERENCES [Children] ([ChildID])

ALTER TABLE [Attendance] CHECK CONSTRAINT [FK_Attendance_ChildID]

ALTER TABLE [Operations] WITH CHECK ADD CONSTRAINT [FK_Operations_ChildID] FOREIGN KEY([ChildID])
REFERENCES [Children] ([ChildID])

ALTER TABLE [Operations] CHECK CONSTRAINT [FK_Operations_ChildID]

ALTER TABLE [Operations] 
ADD CONSTRAINT constr_operationType 
		CHECK (OperationType in ('начисление', 'погашение'));

CREATE INDEX [idx_Children_Name]
ON [Children] ([Name])

CREATE INDEX [idx_Adults_Name]
ON [Adults] ([Name])

CREATE INDEX [idx_Groups_Name]
ON [Groups] ([Name])

CREATE INDEX [idx_Food_Name]
ON [Food] ([Name])

CREATE INDEX [idx_Menu_Date]
ON [Menu] ([Date])

CREATE INDEX [idx_Attendance_Date]
ON [Attendance] ([Date])


COMMIT TRANSACTION QUICKDBD
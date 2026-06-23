CREATE TABLE [Children] (
  [ChildID] int NOT NULL,
  [Name] string NOT NULL,
  [Birthday] date NOT NULL,
  [Address] string NOT NULL,
  [MotherID] int,
  [FatherID] int,
  PRIMARY KEY ([ChildID])
)
GO

CREATE TABLE [Adults] (
  [AdultID] int NOT NULL,
  [Name] string NOT NULL,
  [Birthday] date NOT NULL,
  [Address] string NOT NULL,
  [Phone] string NOT NULL,
  [Email] string,
  [Job] string NOT NULL,
  [Education] string NOT NULL,
  [IsKindergartenTeacher] bit NOT NULL,
  PRIMARY KEY ([AdultID])
)
GO

CREATE TABLE [Groups] (
  [GroupID] int NOT NULL,
  [Name] string NOT NULL,
  [Age] string NOT NULL,
  [IsNursery] bit NOT NULL,
  PRIMARY KEY ([GroupID])
)
GO

CREATE TABLE [b_Children_Groups] (
  [ChildID] int NOT NULL,
  [GroupID] int NOT NULL
)
GO

CREATE TABLE [b_Adults_Groups] (
  [AdultID] int NOT NULL,
  [GroupID] int NOT NULL
)
GO

CREATE TABLE [Sections] (
  [SectionID] int NOT NULL,
  [Name] string NOT NULL,
  [Price ] decimal NOT NULL,
  PRIMARY KEY ([SectionID])
)
GO

CREATE TABLE [b_Children_Sections] (
  [ChildID] int NOT NULL,
  [SectionID] int NOT NULL
)
GO

CREATE TABLE [b_Adults_Sections] (
  [AdultID] int NOT NULL,
  [SectionID] int NOT NULL
)
GO

CREATE TABLE [Food] (
  [FoodID] int NOT NULL,
  [Name] string NOT NULL,
  [ServingSizeNursery] int NOT NULL,
  [ServingSizeKindergarten] int NOT NULL,
  [Calories] int NOT NULL,
  PRIMARY KEY ([FoodID])
)
GO

CREATE TABLE [Menu] (
  [Date] date NOT NULL,
  [MealTime] string NOT NULL,
  [FoodID] int NOT NULL,
  [ServingSizeNursery] int NOT NULL,
  [ServingSizeKindergarten] int NOT NULL,
  [CaloriesNursery] int NOT NULL,
  [CaloriesKindergarten] int NOT NULL
)
GO

CREATE TABLE [Attendance] (
  [Date] date NOT NULL,
  [GroupID] int NOT NULL,
  [ChildID] int NOT NULL,
  [SectionID] int
)
GO

CREATE TABLE [Operations] (
  [OperationID] int NOT NULL,
  [ChildID] int NOT NULL,
  [Date] date NOT NULL,
  [Amount] decimal NOT NULL,
  [OperationType] string NOT NULL,
  [SectionID] int,
  PRIMARY KEY ([OperationID])
)
GO

CREATE INDEX [idx_Children_Name] ON [Children] ("Name")
GO

CREATE INDEX [idx_Adults_Name] ON [Adults] ("Name")
GO

CREATE INDEX [idx_Groups_Name] ON [Groups] ("Name")
GO

CREATE INDEX [idx_Sections_Name] ON [Sections] ("Name")
GO

CREATE INDEX [idx_Food_Name] ON [Food] ("Name")
GO

CREATE INDEX [idx_Menu_Date] ON [Menu] ("Date")
GO

CREATE INDEX [idx_Attendance_Date] ON [Attendance] ("Date")
GO

CREATE INDEX [idx_Attendance_ChildID] ON [Attendance] ("ChildID")
GO

CREATE INDEX [idx_Attendance_SectionID] ON [Attendance] ("SectionID")
GO

ALTER TABLE [Children] ADD CONSTRAINT [FK_Children_MotherID] FOREIGN KEY ([MotherID]) REFERENCES [Adults] ([AdultID])
GO

ALTER TABLE [Children] ADD CONSTRAINT [FK_Children_FatherID] FOREIGN KEY ([FatherID]) REFERENCES [Adults] ([AdultID])
GO

ALTER TABLE [b_Children_Groups] ADD CONSTRAINT [FK_b_Children_Groups_ChildID] FOREIGN KEY ([ChildID]) REFERENCES [Children] ([ChildID])
GO

ALTER TABLE [b_Children_Groups] ADD CONSTRAINT [FK_b_Children_Groups_GroupID] FOREIGN KEY ([GroupID]) REFERENCES [Groups] ([GroupID])
GO

ALTER TABLE [b_Adults_Groups] ADD CONSTRAINT [FK_b_Adults_Groups_AdultID] FOREIGN KEY ([AdultID]) REFERENCES [Adults] ([AdultID])
GO

ALTER TABLE [b_Adults_Groups] ADD CONSTRAINT [FK_b_Adults_Groups_GroupID] FOREIGN KEY ([GroupID]) REFERENCES [Groups] ([GroupID])
GO

ALTER TABLE [Menu] ADD CONSTRAINT [FK_Menu_FoodID] FOREIGN KEY ([FoodID]) REFERENCES [Food] ([FoodID])
GO

ALTER TABLE [Attendance] ADD CONSTRAINT [FK_Attendance_GroupID] FOREIGN KEY ([GroupID]) REFERENCES [Groups] ([GroupID])
GO

ALTER TABLE [Attendance] ADD CONSTRAINT [FK_Attendance_ChildID] FOREIGN KEY ([ChildID]) REFERENCES [Children] ([ChildID])
GO

ALTER TABLE [Operations] ADD CONSTRAINT [FK_Operations_ChildID] FOREIGN KEY ([ChildID]) REFERENCES [Children] ([ChildID])
GO

ALTER TABLE [b_Children_Sections] ADD FOREIGN KEY ([SectionID]) REFERENCES [Sections] ([SectionID])
GO

ALTER TABLE [b_Adults_Sections] ADD FOREIGN KEY ([SectionID]) REFERENCES [Sections] ([SectionID])
GO

ALTER TABLE [b_Children_Sections] ADD FOREIGN KEY ([ChildID]) REFERENCES [Children] ([ChildID])
GO

ALTER TABLE [b_Adults_Sections] ADD FOREIGN KEY ([AdultID]) REFERENCES [Adults] ([AdultID])
GO

# logicappsqlcontest

## Database Schema
Create:
```
CREATE TABLE multiplication (
	ID int NOT NULL IDENTITY PRIMARY KEY,
    multiplier int,
    multiplicand int,
	product int DEFAULT 0,
	sum int DEFAULT 0,
	createdDate DATETIME DEFAULT GETDATE(),
	updatedDate DATETIME DEFAULT GETDATE(),
);
```
Insert:
```
INSERT INTO multiplication (multiplier, multiplicand) VALUES (1, 1);
```
Select:
```
SELECT TOP (1000) * FROM [dbo].[multiplication] ORDER BY updatedDate DESC
```
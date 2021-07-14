# logicappsqlcontest

## Database Schema
```
CREATE TABLE multiplication (
	ID int NOT NULL IDENTITY PRIMARY KEY,
    multiplier int,
    multiplicand int,
	product int DEFAULT 0,
	createdDate DATETIME DEFAULT GETDATE(),
	updatedDate DATETIME DEFAULT GETDATE(),
);
```
```
INSERT INTO multiplication (multiplier, multiplicand) VALUES (1, 1);
```
```
SELECT TOP (1000) * FROM [dbo].[multiplication]
```
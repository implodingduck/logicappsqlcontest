# logicappsqlcontest

## Database Schema
```
CREATE TABLE multiplication (
	ID int NOT NULL IDENTITY PRIMARY KEY,
    multiplier int,
    multiplicand int,
	product int,
	createdDate DATETIME DEFAULT GETDATE(),
	updatedDate DATETIME DEFAULT GETDATE(),
);
```
/* 1) STORED PROCEDURE 1 for transactional table CUSTOMER
    goal: check whether a customer has an ID already, and if not create one for them by checking if email has already been added*/

CREATE PROCEDURE dbo.CheckandCreateCustomerID
    @OrderID INT,
    @CustomerFName VARCHAR(75),
    @CustomerLName VARCHAR(75),
    @CustomerEmail VARCHAR(100), 
    @CustomerPhoneNo VARCHAR(15)
AS
BEGIN
    IF (@OrderID IS NULL OR @CustomerFName IS NULL OR @CustomerLName IS NULL OR @CustomerEmail IS NULL OR @CustomerPhoneNo IS NULL)
    BEGIN 
        THROW 51000, 'Customer information cannot be empty. Fill in all values to proceed.', 1
        RETURN 
    END 

    DECLARE @CustomerID INT

    -- check if customer already exists by email
    SELECT @CustomerID = CustomerID
    FROM CUSTOMER
    WHERE CustomerEmail = @CustomerEmail

    -- if it doesn't exist
    IF @CustomerID IS NULL
    BEGIN
        INSERT INTO dbo.CUSTOMER (CustomerFName, CustomerLName, CustomerEmail, CustomerPhoneNo)
        VALUES (@CustomerFName, @CustomerLName, @CustomerEmail, @CustomerPhoneNo)

        --assign new customer id
        SET @CustomerID = SCOPE_IDENTITY()

        -- add CustomerID to CUSTOMER_ORDER w/new ID
        UPDATE dbo.CUSTOMER_ORDER
        SET CustomerID = @CustomerID
        WHERE OrderID = @OrderID
    END
    ELSE
    BEGIN
        RAISERROR('CustomerID already exists.', 11, 1)
        RETURN
    END
END;

/* 2) TRIGGER 1 
    This trigger is created after the stored procedure to check if customer is in system already after an order is placed */

CREATE TRIGGER trg_CustomerID_AfterOrderPlaced
ON dbo.CUSTOMER_ORDER
AFTER INSERT
AS 
BEGIN 
    DECLARE @OrderID INT
    DECLARE @CustomerFName VARCHAR(75)
    DECLARE @CustomerLName VARCHAR(75)
    DECLARE @CustomerEmail VARCHAR(100)
    DECLARE @CustomerPhoneNo VARCHAR(15)

-- loop through rows with SQL cursor as "cur"
    DECLARE cur CURSOR FOR
    SELECT i.OrderID, c.CustomerFName, c.CustomerLName, c.CustomerEmail, c.CustomerPhoneNo
    FROM INSERTED i
    JOIN dbo.CUSTOMER_ORDER co ON i.OrderID = co.OrderID
    JOIN dbo.CUSTOMER c ON co.CustomerID = c.CustomerID

    OPEN cur
    FETCH NEXT FROM cur INTO @OrderID, @CustomerFName, @CustomerLName, @CustomerEmail, @CustomerPhoneNo

    WHILE @@FETCH_STATUS = 0 
        BEGIN
        EXEC dbo.CheckandCreateCustomerID
            @OrderID = @OrderID, 
            @CustomerFName = @CustomerFName, 
            @CustomerLName = @CustomerLName, 
            @CustomerEmail = @CustomerEmail, 
            @CustomerPhoneNo = @CustomerPhoneNo
        FETCH NEXT FROM cur INTO @OrderID, @CustomerFName, @CustomerLName, @CustomerEmail, @CustomerPhoneNo
    END
    CLOSE cur 
    DEALLOCATE cur 
END;

/* 3) STORED PROCEDURE 2 for transactional table -check if any ingredients in the inventory are below threshold*/

CREATE PROCEDURE dbo.CheckInventoryLevel
    @IngredientID INT,
    @QuantityAvailable INT
AS 
BEGIN 

    IF (@IngredientID IS NULL OR @QuantityAvailable IS NULL)
    BEGIN 
        THROW 51000, 'Need both the ingredient ID and current quantity available to proceed.', 1
        RETURN 
    END 

    DECLARE @StockThreshold INT = 12
    DECLARE @OrderDate DATETIME = GETDATE()

    IF EXISTS (
        SELECT *
        FROM INVENTORY
        WHERE IngredientID = @IngredientID
            AND QuantityAvailable <= @StockThreshold
    )
    BEGIN
        INSERT INTO INGREDIENT_ORDERS(IngredientID, VendorID, QuantityOrdered, OrderDate)
        SELECT i.IngredientID, i.VendorID, @StockThreshold - i.QuantityAvailable AS AmountToReplenish, @OrderDate
        FROM INVENTORY i
        WHERE i.IngredientID = @IngredientID
            AND i.QuantityAvailable <= @StockThreshold 
            AND NOT EXISTS(
                SELECT 1
                FROM INGREDIENT_ORDERS io 
                WHERE io.IngredientID = i.IngredientID 
                    AND io.VendorID = i.VendorID
            )
    END
END;

/* 4) TRIGGER 2 to fire up an Ingredient order for restock when quantity in inventory falls below a specific number*/

CREATE TRIGGER trg_OrderMoreIngredients
ON dbo.INVENTORY
AFTER UPDATE
AS 
BEGIN 
    EXEC dbo.CheckInventoryLevel
END;

/* 5) FIRST COMPUTED COLUMN(s) to calculate the order cost of the ingredients restock */

CREATE FUNCTION dbo.function_calculate_restock_cost(@IngredientID INT)
RETURNS NUMERIC (10,2)
AS
BEGIN
    DECLARE @IngredientOrderCost NUMERIC(10,2)

    SELECT @IngredientOrderCost = io.QuantityOrdered * (
        (SELECT i.CostUnit
        FROM INGREDIENTS i
        WHERE i.IngredientID = io.IngredientID) + 
        (SELECT s.VendorFee
        FROM SUPPLIERS s
        WHERE s.VendorID = io.VendorID))
    FROM INGREDIENT_ORDERS io 
    WHERE io.IngredientID = @IngredientID
        
    RETURN @IngredientOrderCost
END;

-- add cost column to ingredient orders table
ALTER TABLE INGREDIENT_ORDERS
ADD OrderCost AS (dbo.function_calculate_restock_cost(IngredientID));


/* 6) SECOND COMPUTED COLUMN: converting the price column in RECIPES table to computed */

    -- remove price column as its non-computed form
    ALTER TABLE RECIPES
    DROP COLUMN Price;

    --create a function to calculate the price based on ingredients used and adding a 10% margin
    CREATE FUNCTION dbo.function_calculate_recipe_cost (@RecipeID INT)
    RETURNS NUMERIC (10,2)
    AS
        BEGIN
        DECLARE @TotalCost NUMERIC(10,2)

        SELECT @TotalCost = ISNULL(SUM(i.CostUnit), 0)
        FROM RECIPE_INGREDIENTS ri 
        JOIN INGREDIENTS i ON ri.IngredientID = i.IngredientID
        WHERE ri.RecipeID = @RecipeID

        RETURN @TotalCost * 1.10
    END; 

    -- add price column
    ALTER TABLE RECIPES
    ADD Price AS (dbo.function_calculate_recipe_cost(RecipeID));

/* 7) COMPLEX QUERY 1:  find the top 3 baked goods that are most popular with customers,
 what time of day these items are typically ordered at most often (early morning between 6-9AM, morning 9-11:59AM, afternoon 12-3PM), 
 and calculate total profits from each item
 and rank these popular recipes by largest profit as 1 to lowest as 3 
*/
-- using 3 CTEs to store values temporarily for a final query combining all results

WITH TopRecipeCounts AS (
    SELECT r.RecipeID, r.RecipeName, COUNT(*) AS OrderCount, SUM(r.Price) AS TotalProfit
    FROM RECIPES r 
    JOIN CUSTOMER_ORDER co ON r.RecipeID = co.RecipeID
    GROUP BY r.RecipeID, r.RecipeName
), 

RecipeOrderTimes AS (
    SELECT r.RecipeID, r.RecipeName,
    CASE 
        WHEN DATEPART(HOUR, co.Placed) BETWEEN 6 AND 9
            THEN 'Early Morning'
        WHEN DATEPART(HOUR, co.Placed) BETWEEN 9 AND 12
            THEN 'Morning'
        WHEN DATEPART(HOUR, co.Placed) BETWEEN 12 AND 15
            THEN 'Afternoon'
        ELSE 'Outside business hours'
    END AS OrderTimes, COUNT(*) AS CountOrderTimes

    FROM RECIPES r 
    JOIN CUSTOMER_ORDER co ON r.RecipeID = co.RecipeID
    GROUP BY r.RecipeID, r.RecipeName,
    CASE 
        WHEN DATEPART(HOUR, co.Placed) BETWEEN 6 AND 9
            THEN 'Early Morning'
        WHEN DATEPART(HOUR, co.Placed) BETWEEN 9 AND 12
            THEN 'Morning'
        WHEN DATEPART(HOUR, co.Placed) BETWEEN 12 AND 15
            THEN 'Afternoon'
        ELSE 'Outside business hours'
    END
), 

TopRecipes AS (
    SELECT trc.RecipeID, trc.RecipeName, trc. OrderCount, trc.TotalProfit, DENSE_RANK() OVER (ORDER BY trc.TotalProfit DESC) AS ProfitRank
    FROM TopRecipeCounts trc
)

-- query using the CTEs above
SELECT TOP 3 tr.RecipeName, rot.OrderTimes AS 'Popular order times of day', tr.TotalProfit, tr.ProfitRank
FROM TopRecipes tr
JOIN RecipeOrderTimes rot ON rot.RecipeID = tr.RecipeID
    AND rot.CountOrderTimes = (
        SELECT MAX(rot.CountOrderTimes)
        FROM RecipeOrderTimes rot
        WHERE rot.RecipeID = tr.RecipeID
        )
ORDER BY tr.ProfitRank;

/* 8) COMPLEX QUERY 2: find the maintenance vendors we contract with that have the highest hourly fees,
and find how many services they typically perform for bakery, 
as well as the average amount billed across these services*/

SELECT mv.MaintenanceVendorID, mv.RateperHour, COUNT(DISTINCT(m.MaintenanceTicketID)) AS NumServicesPerformed, AVG(m.TotalCost) AS AverageAmountBilledperService
FROM MAINTENANCE_VENDORS mv
JOIN MAINTENANCE m ON mv.MaintenanceVendorID = m.MaintenanceVendorID
WHERE mv.RateperHour = (
    SELECT MAX(RateperHour)
    FROM MAINTENANCE_VENDORS
)
GROUP BY mv.MaintenanceVendorID, mv.RateperHour
ORDER BY AVG(m.TotalCost) DESC;


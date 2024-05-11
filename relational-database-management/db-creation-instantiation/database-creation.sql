-- to restart:
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'BakeryDB')
    DROP DATABASE BakeryDB;


-- create DB: this has been run already!
CREATE DATABASE BakeryDB

-- to create tables
USE BakeryDB;
GO

--CREATE 'DEPARTMENT' TABLE
CREATE TABLE DEPARTMENT(
    DeptID INT IDENTITY PRIMARY KEY,
    DeptName VARCHAR(50) NOT NULL,
    Responsibilities VARCHAR(200) NOT NULL
);

--create employment_type table
CREATE TABLE EMPLOYMENT_TYPE(
    EmploymentID INT IDENTITY PRIMARY KEY,
    EmployeeRole VARCHAR(75) NOT NULL,
    EmployeeSalary NUMERIC(10,2) NOT NULL,
    DeptID INT FOREIGN KEY REFERENCES dbo.DEPARTMENT(DeptID),
)

-- tools table
CREATE TABLE TOOLS(
    ToolID INT IDENTITY PRIMARY KEY,
    ToolName VARCHAR(100) NOT NULL,
    ToolDescription VARCHAR(200) NOT NULL,
    ToolStatus VARCHAR(50) NOT NULL
)
--suppliers table
CREATE TABLE SUPPLIERS(
    VendorID INT IDENTITY PRIMARY KEY,
    DeliveryDays VARCHAR(150) NOT NULL,
    VendorPhoneNo VARCHAR(15) NOT NULL,
    VendorFee NUMERIC(10, 2) NOT NULL
)
-- ingredients table
CREATE TABLE INGREDIENTS(
    IngredientID INT IDENTITY PRIMARY KEY,
    IngredientName VARCHAR(150) UNIQUE NOT NULL,
    CostUnit NUMERIC(10,2) NOT NULL
)

-- inventory table
CREATE TABLE INVENTORY(
    IngredientID INT NOT NULL,
    VendorID INT NOT NULL, 
    QuantityAvailable INT NOT NULL,
    DaysShelfLife INT NOT NULL,
    Storage VARCHAR(150) NOT NULL,
    PRIMARY KEY (IngredientID, VendorID), -- set composite primary key
    FOREIGN KEY (IngredientID) REFERENCES dbo.INGREDIENTS(IngredientID),
    FOREIGN KEY (VendorID) REFERENCES dbo.SUPPLIERS(VendorID)
)

-- equipment table
CREATE TABLE EQUIPMENT(
    EquipmentID INT IDENTITY PRIMARY KEY,
    EquipmentName VARCHAR(200) NOT NULL,
    EquipmentDescription VARCHAR(500) NOT NULL,
    EquipmentStatus VARCHAR(50) NOT NULL,
    MaintenanceSched VARCHAR(500) NOT NULL,
)

-- maintenance vendors table
CREATE TABLE MAINTENANCE_VENDORS(
    MaintenanceVendorID INT IDENTITY PRIMARY KEY,
    MaintenanceVendorPhoneNo VARCHAR(10) NOT NULL,
    RateperHour NUMERIC(10,2) NOT NULL,
)

-- repairs table
CREATE TABLE REPAIRS(
    RepairTicketID INT IDENTITY PRIMARY KEY,
    EquipmentID INT FOREIGN KEY REFERENCES dbo.EQUIPMENT(EquipmentID),
    Comments VARCHAR(1000) NOT NULL,
    SubmittedDate DATETIME NOT NULL,
    DateStartedRepair DATETIME NOT NULL,
    DateEndedRepair DATETIME NOT NULL,
    MaintenanceVendorID INT FOREIGN KEY REFERENCES dbo.MAINTENANCE_VENDORS(MaintenanceVendorID),
    RateperHour NUMERIC(10,2) NOT NULL,
    HoursBilled AS (DATEDIFF (HOUR, DateStartedRepair, DateEndedRepair)),
    TotalCost AS ((DATEDIFF (HOUR, DateStartedRepair, DateEndedRepair)) * RateperHour),

)
-- maintenance table
CREATE TABLE MAINTENANCE(
    MaintenanceTicketID INT IDENTITY PRIMARY KEY,
    EquipmentID INT FOREIGN KEY REFERENCES dbo.EQUIPMENT(EquipmentID),
    MaintenanceDescription VARCHAR(1000) NOT NULL,
    MaintenanceVendorID INT FOREIGN KEY REFERENCES dbo.MAINTENANCE_VENDORS(MaintenanceVendorID),
    DateStartedWork DATETIME NOT NULL,
    DateEndedWork DATETIME NOT NULL,
    RateperHour NUMERIC(10,2) NOT NULL,
    HoursBilled AS (DATEDIFF (HOUR, DateStartedWork, DateEndedWork)),
    TotalCost AS ((DATEDIFF (HOUR, DateStartedWork, DateEndedWork)) * RateperHour),
)

-- recipes table
CREATE TABLE RECIPES(
    RecipeID INT IDENTITY PRIMARY KEY,
    RecipeName VARCHAR(200) NOT NULL,
    Directions VARCHAR(1000) NOT NULL,
    ServingSize INT NOT NULL,
    ToolID INT FOREIGN KEY REFERENCES dbo.TOOLS(ToolID),
    EquipmentID INT FOREIGN KEY REFERENCES dbo.EQUIPMENT(EquipmentID),
    DeptID INT FOREIGN KEY REFERENCES dbo.DEPARTMENT(DeptID),
    Price NUMERIC (10,2) NOT NULL
)


-- association table to connect ingredients table to recipes table and account for the many to many relationship where a recipe can have more than 1 ingredient and an ingredient can be used in more than 1 recipe
CREATE TABLE RECIPE_INGREDIENTS(
    RecipeID INT,
    IngredientID INT,
    CONSTRAINT PK_RECIPE_INGREDIENTS PRIMARY KEY (RecipeID, IngredientID), --serves as PK to ensure uniqueness of recipe/ingredient pairs
    FOREIGN KEY (RecipeID) REFERENCES dbo.RECIPES(RecipeID),
    FOREIGN KEY (IngredientID) REFERENCES INGREDIENTS(IngredientID)
)

-- 3 menu table
CREATE TABLE MENU(
    MenuID INT IDENTITY PRIMARY KEY,
    MenuName VARCHAR(100) NOT NULL,
    RecipeID INT FOREIGN KEY REFERENCES dbo.RECIPES(RecipeID)

)
-- association table to connect menus + recipes
CREATE TABLE MENU_RECIPES(
    MenuID INT,
    RecipeID INT,
    CONSTRAINT PK_MENU_RECIPES PRIMARY KEY (MenuID, RecipeID),
    FOREIGN KEY (MenuID) REFERENCES dbo.MENU(MenuID),
    FOREIGN KEY(RecipeID) REFERENCES dbo.RECIPES(RecipeID)
)

-- create bakery_branch table
CREATE TABLE BAKERY_BRANCH(
    BakeryID INT IDENTITY PRIMARY KEY,
    BakeryStreetAddress VARCHAR(200) NOT NULL,
    BakeryCity VARCHAR(100) NOT NULL,
    BakeryState VARCHAR(2) NOT NULL,
    BakeryZIP VARCHAR(10) NOT NULL,
    BakeryPhoneNo VARCHAR(15) NOT NULL,
    MenuID INT FOREIGN KEY REFERENCES dbo.MENU(MenuID)
)

--CREATE 'EMPLOYEE' TABLE
CREATE TABLE EMPLOYEE(
    EmployeeID INT IDENTITY PRIMARY KEY,
    EmployeeFName VARCHAR(75) NOT NULL,
    EmployeeLName VARCHAR(75) NOT NULL,
    EmploymentID INT FOREIGN KEY REFERENCES dbo.EMPLOYMENT_TYPE(EmploymentID),
    BakeryID INT FOREIGN KEY REFERENCES dbo.BAKERY_BRANCH(BakeryID),
    EmployeePhoneNo VARCHAR(15) NOT NULL
)

-- customer table
CREATE TABLE CUSTOMER(
    CustomerID INT IDENTITY PRIMARY KEY,
    CustomerFName VARCHAR(75) NOT NULL,
    CustomerLName VARCHAR(75) NOT NULL,
    CustomerEmail VARCHAR(100) NOT NULL,
    CustomerPhoneNo VARCHAR(15) NOT NULL
)

-- order table
CREATE TABLE CUSTOMER_ORDER(
    OrderID INT IDENTITY PRIMARY KEY,
    Placed DATETIME NOT NULL,
    CustomerID INT FOREIGN KEY REFERENCES dbo.CUSTOMER(CustomerID),
    RecipeID INT FOREIGN KEY REFERENCES dbo.RECIPES(RecipeID),
    Quantity INT NOT NULL,
    BakeryID INT FOREIGN KEY REFERENCES dbo.BAKERY_BRANCH(BakeryID)
)

USE BakeryDB;
GO

-- inspected successful creation of tables
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';


-- removed couple of columns from recipes table
ALTER TABLE RECIPES
DROP CONSTRAINT FK__RECIPES__ToolID__52593CB8;
ALTER TABLE RECIPES
DROP COLUMN ToolID;

ALTER TABLE RECIPES
DROP CONSTRAINT FK__RECIPES__Equipme__534D60F1;
ALTER TABLE RECIPES
DROP COLUMN EquipmentID;


-- changed MENU table, removed RecipeID and referenced deptid instead
ALTER TABLE MENU
DROP CONSTRAINT FK__MENU__RecipeID__5AEE82B9;
ALTER TABLE MENU
DROP COLUMN RecipeID;

ALTER TABLE MENU
ADD DeptID INT FOREIGN KEY REFERENCES dbo.DEPARTMENT(DeptID);
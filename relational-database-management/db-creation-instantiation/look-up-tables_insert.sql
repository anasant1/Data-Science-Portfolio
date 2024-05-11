-- tables that don't need insert for now:
-- recipe_ingredients (association table), menu_recipes (association table), employee, customer, customer_order, transactional tables:  maintenance, repairs, inventory

--dept table insertions, done
INSERT INTO DEPARTMENT VALUES('Janitorial', 'Clean facilities');
INSERT INTO DEPARTMENT VALUES('Pastry', 'Bake pastries for branches');
INSERT INTO DEPARTMENT VALUES('Cake', 'Bake cakes for branches');
INSERT INTO DEPARTMENT VALUES('Clerk', 'Facilitate in-store sales');
INSERT INTO DEPARTMENT VALUES('Managerial', 'Maintain inventory, coordinate other department functions');

-- employment_type insertions, done
INSERT INTO EMPLOYMENT_TYPE VALUES('Janitor', 35000, 1);
INSERT INTO EMPLOYMENT_TYPE VALUES('Pastry Head Chef', 50000, 2);
INSERT INTO EMPLOYMENT_TYPE VALUES('Cake Decorator', 45000, 3);
INSERT INTO EMPLOYMENT_TYPE VALUES('Cashier', 30000, 4);
INSERT INTO EMPLOYMENT_TYPE VALUES('Bakery manager', 45000, 5);

--tools insertions, done
INSERT INTO TOOLS VALUES('Copper canele pans', 'Containers to bake caneles', 'Functional');
INSERT INTO TOOLS VALUES('Whisk', 'Whisks ingredients', 'Functional');
INSERT INTO TOOLS VALUES('Rolling pin', 'Flattens pastry dough', 'Needs replacement');
INSERT INTO TOOLS VALUES('Cake decorating stand', 'Facilitates cake decorating activities', 'Out of service');
INSERT INTO TOOLS VALUES('Cookie baking pan', 'Pan to bake cookies', 'Functional');

-- suppliers insertions, done
INSERT INTO SUPPLIERS VALUES('Monday, Friday', '2066794835', 150);
INSERT INTO SUPPLIERS VALUES('Wednesday', '2069815464', 50);
INSERT INTO SUPPLIERS VALUES('Monday', '2069993452', 75);
INSERT INTO SUPPLIERS VALUES('Friday', '2063549785', 100);
INSERT INTO SUPPLIERS VALUES('Wednesday', '2063129874', 50);

-- ingredients insertions, done
INSERT INTO INGREDIENTS VALUES ('Eggs', .05);
INSERT INTO INGREDIENTS VALUES ('Milk', 3.00);
INSERT INTO INGREDIENTS VALUES ('Flour', 15.25);
INSERT INTO INGREDIENTS VALUES ('Chocolate powder', 22.35);
INSERT INTO INGREDIENTS VALUES ('Vanilla', 17.30);

-- equipment insertions, done
INSERT INTO EQUIPMENT VALUES('Stand-mixer', 'Mixes ingredients in batches', 'Functional', 'Yearly');
INSERT INTO EQUIPMENT VALUES('Oven', 'Bakes', 'Functional', 'Monthly');
INSERT INTO EQUIPMENT VALUES('Dishwasher', 'Washes tools', 'Out of order', 'Yearly');
INSERT INTO EQUIPMENT VALUES('Pan Rack', 'Holds pastries to cool down', 'Functional', 'Yearly');
INSERT INTO EQUIPMENT VALUES('Dough Divider', 'Divides dough', 'Out of order', 'Yearly');

--maint vendors insertions, done
INSERT INTO MAINTENANCE_VENDORS VALUES('2069843256', 25);
INSERT INTO MAINTENANCE_VENDORS VALUES('5129753214', 30);
INSERT INTO MAINTENANCE_VENDORS VALUES('6219853266', 25);
INSERT INTO MAINTENANCE_VENDORS VALUES('3219874521', 20);
INSERT INTO MAINTENANCE_VENDORS VALUES('4129856245', 15);

-- recipes insertions, done
INSERT INTO RECIPES VALUES('Banana bread', 'Combine ingredients, bake at...', 8, 2, 3.50);
INSERT INTO RECIPES VALUES('Red velvet cupcake', 'Combine ingredients, bake at...', 1, 2, 4.25);
INSERT INTO RECIPES VALUES('Baguette', 'Combine ingredients, bake at...', 8, 2, 2.00);
INSERT INTO RECIPES VALUES('Bundt Cake', 'Combine ingredients, bake at...', 16, 3, 15.75);
INSERT INTO RECIPES VALUES('Tres leches cake', 'Combine ingredients, bake at...', 20, 3, 25.35);

--menu insertions, done
INSERT INTO MENU VALUES('Pastry Menu', 2);
INSERT INTO MENU VALUES('Cake Menu', 3);

-- bakery branch insertions, done
INSERT INTO BAKERY_BRANCH VALUES('854 Fairview Ave', 'Seattle', 'WA', '98101', '2068743685', 2);
INSERT INTO BAKERY_BRANCH VALUES('400 E 38th-1/2 Street', 'Austin', 'TX', '78722', '5128759999', 1);
INSERT INTO BAKERY_BRANCH VALUES('773 Market St', 'San Francisco', 'CA', '94103', '5843657878', 1);
INSERT INTO BAKERY_BRANCH VALUES('603 SE 3rd St', 'Bend', 'OR', '97701', '2049862314', 2);
INSERT INTO BAKERY_BRANCH VALUES('1005 E Pike St', 'Seattle', 'WA', '98122', '2065781154', 1);

--10 lookup



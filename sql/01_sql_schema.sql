
-- Query for create Customers
CREATE TABLE CUSTOMERS (
  customer_id INT PRIMARY KEY,
  name VARCHAR(100),
  region VARCHAR(50)
);

-- Query for create Products
CREATE TABLE PRODUCTS (
  product_id INT PRIMARY KEY,
  name VARCHAR(100) UNIQUE,
  category VARCHAR(50)
);

-- Query for create Transactions
CREATE TABLE TRANSACTIONS (
  transaction_id INT PRIMARY KEY,
  customer_id INT,
  product_id INT,
  sale_date DATE,
  amount DECIMAL(10,2),
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

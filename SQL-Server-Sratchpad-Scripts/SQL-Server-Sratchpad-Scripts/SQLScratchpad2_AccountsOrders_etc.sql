DROP TABLE IF EXISTS dbo.my_orders;
DROP TABLE IF EXISTS dbo.my_accounts;

SELECT *
  INTO dbo.my_accounts
  FROM (
    VALUES 
      ('C', '0001', 'Customer A'),
      ('C', '0002', 'Customer B'),
      ('C', '0003', 'Customer C'),
      ('C', '0004', 'Customer D'),
      ('S', '0001', 'Supplier A'),
      ('S', '0002', 'Supplier B')
  ) AS accounts(account_type, account_code, account_name);

 ALTER TABLE dbo.my_accounts
   ADD CONSTRAINT my_accounts_pk PRIMARY KEY (account_type, account_code);

SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) order_number,
       CAST(DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 1000), '2015-01-01') AS DATE) order_date,
       CAST((ABS(CHECKSUM(NEWID()) % 10) +1) * 1000 AS MONEY) order_total,
       c.account_type AS customer_account_type,
       c.account_code AS customer_account_code,
       s.account_type AS supplier_account_type,
       s.account_code AS supplier_account_code
  INTO dbo.my_orders
  FROM dbo.my_accounts AS c
  CROSS JOIN dbo.my_accounts AS s
  CROSS JOIN dbo.getNums(1, 10) AS nums
 WHERE c.account_type = 'C'
   AND s.account_type = 'S';

ALTER TABLE dbo.my_orders
  ALTER COLUMN order_number INT NOT NULL;

ALTER TABLE dbo.my_orders
  ADD CONSTRAINT my_orders_pk PRIMARY KEY(order_number);

ALTER TABLE dbo.my_orders
  ADD CONSTRAINT my_orders_accounts_cust_fk
  FOREIGN KEY (customer_account_type, customer_account_code)
    REFERENCES dbo.my_accounts (account_type, account_code);

ALTER TABLE dbo.my_orders
  ADD CONSTRAINT my_orders_accounts_sup_fk
  FOREIGN KEY (supplier_account_type, supplier_account_code)
    REFERENCES dbo.my_accounts (account_type, account_code);


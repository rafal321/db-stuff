
# --- 22. Beginning Update Statements ---

SHOW VARIABLES LIKE 'sql_safe_updates';
SET sql_safe_updates=1;
SET sql_safe_updates=0;

# --- 23. Order By ---
# --- 24. Limiting Results ---

select * from users order by Id limit 0, 10;   # default
select * from users order by Id limit 5, 10;

# --- 25. Mysql Types ---
# --- 26. Text Types ---
# --- 27. Floating Point Types and Ints ---
# --- 28. The Bit Type ---
# --- 29. Bool ---
# --- 30. Blobs ---

# --- 31. Time, Date and Year --- # --- 32. Timestamp and Datetime ---
SELECT NOW();
SELECT year(NOW());
SELECT month(NOW());
SELECT time(NOW());
SELECT date(NOW());

CREATE TABLE moments (id INT PRIMARY KEY AUTO_INCREMENT, theYear YEAR, theDate DATE, theTime TIME);
DESC moments;
SELECT * FROM moments;
INSERT INTO moments (theYear, theDate, theTime) VALUES ('2020', '2014-05-15', '8:10:23');
INSERT INTO moments (theYear, theDate, theTime) VALUES (year(NOW()), date(NOW()), time(NOW()));

SELECT day(theDate) FROM moments;
SELECT year(theDate) FROM moments;
SELECT hour(theTime) FROM moments;

# --- 33. Enumerations ---
# --- 34. Brackets and Conditions Revisited ---

# --- 37. The distinct keyword --- # --- 38. Counting Distinct Values ---
SELECT DISTINCT name FROM users;
SELECT COUNT(name) FROM users;
SELECT COUNT(DISTINCT name) FROM users;
SELECT COUNT(DISTINCT NAME, age) FROM users;
# --- 39. Aggregate Functions ---
SELECT MIN(age) FROM users;
# --- 40. Arithmetic in MySQL ---
# --- 42. Group By ---
# --- 43. Having- Restricting Groups By Aggregate ---











# -----------Stored routines 122-114 ----------------------------
CREATE TABLE bank(
acc_id INT NOT NULL AUTO_INCREMENT,
balance numeric(8,2),
PRIMARY KEY (acc_id)
);

INSERT INTO bank (amount) VALUES(410);

DROP PROCEDURE withdraw;

delimiter //
CREATE PROCEDURE withdraw(IN account_id INT, IN amount NUMERIC(8.2), OUT success BOOL)
BEGIN

  DECLARE current_balance NUMERIC(8,2) DEFAULT 0.0;

    DECLARE exit handler for sqlexception
    BEGIN
    SHOW ERRORS;
    END;
    DECLARE exit handler FOR sqlwarning
    BEGIN
    SHOW WARNINGS;
    END;

  START TRANSACTION;

    -- we should also add index to balance column otherwise we lock entire table
    SELECT balance INTO current_balance FROM company1.bank WHERE acc_id=account_id FOR UPDATE;

    if current_balance >= amount then
      UPDATE bank SET balance = balance - amount WHERE acc_id = account_id;
      SET success=TRUE;
      else
      SET success=FALSE;
    END if;

  COMMIT;
END//
delimiter ;


CALL withdrowal(1, 300, @success);
SELECT  @success;
SELECT * FROM bank;

# -----------Loops  117 ----------------------------
# generate random data
USE company1;


SELECT RAND();
SELECT ROUND(RAND());
SELECT NOW();
SELECT date(NOW());
SELECT date(NOW()) - INTERVAL 500 DAY;
SELECT date(NOW()) - INTERVAL ROUND(10000*RAND()) DAY;
SELECT date(NOW()) - INTERVAL FLOOR(10000*RAND()) DAY;

# - - - - - - - -

delimiter $$
create procedure testdata()
begin
declare NUMROWS int default 100000;
declare count int default 0;
   
    declare registered_value date default null;
    declare email_value varchar(40) default null;
    declare active_value boolean default false;

drop table if exists users;

create table users (id int auto_increment primary key, email varchar(40) not null, registered date not null,
active boolean default false);

while count < NUMROWS do
   
set registered_value := date(now()) - interval floor(10000*rand()) day;
        set active_value := round(rand());
        set email_value := concat("user", count, "@myemail.com");
       
        insert into users (email, registered, active) values (email_value, registered_value, active_value);
   
set count := count + 1;
    end while;
end$$
delimiter ;

DROP PROCEDURE testdata;

call testdata();

SELECT * FROM users LIMIT 20;
SELECT COUNT(*) FROM users;


# ----------- cursors 117 ----------------------------



SELECT COUNT(*) FROM users WHERE active=TRUE AND registered > DATE (NOW()) - INTERVAL 2 DAY;
SELECT email FROM users WHERE active=TRUE AND registered > DATE (NOW()) - INTERVAL 2 DAY;

delimiter $$


create procedure cursortest()
begin

declare the_email varchar(40);
    declare finished boolean default false;

declare cur1 cursor for select email from users where active = true and registered > date(now()) - interval 1 year;
   
    declare continue handler for not found set finished := true;
   
    delete from leads;
   
open cur1;
   
    the_loop: loop

fetch cur1 into the_email;
       
        if finished then
leave the_loop;
end if;
       
        insert into leads (email) values (the_email);
   
    end loop the_loop;

close cur1;

end$$

delimiter ;


create table leads(id int auto_increment primary key, email varchar(40) not null);
call cursortest();

SELECT COUNT(*) FROM leads;
SELECT * FROM leads LIMIT 10;
 # why use cursor if we can use this:
CREATE TABLE users2 AS SELECT * FROM users LIMIT 10;
CREATE TABLE users3 AS SELECT email FROM users LIMIT 10;

# ----- 125 triggers ----------------------------
USE company1;

create table sales(
id int primary KEY AUTO_INCREMENT,
product varchar(30) not NULL,
value numeric(10,2));

create table sales_update(
id int primary key auto_increment, 
product_id int not null, 
changed_at timestamp,
before_value numeric(10,2) not null, 
after_value numeric(10,2) not NULL);
# - - - - - -

INSERT INTO sales (product, VALUE) VALUES('Onion', 0.10);
UPDATE sales SET VALUE = 4.22 WHERE id = 1;
SELECT * FROM sales;

# events: Update, Insert, Delete   time: Before, After

delimiter $$
create trigger before_sales_update before update on sales for each row
begin

	insert into sales_update(product_id, changed_at, before_value, after_value)
		value (old.id, now(), old.value, new.value);

end$$
delimiter ;

SELECT * FROM sales_update;

# ----- 126 trigger validation ---------------------

drop table products;
create table products (id int primary key auto_increment, value numeric(10,2) not null);

set delimiter $$
create trigger before_products_insert before insert on products for each row
begin

	if new.value > 100.0 then
		set new.value := 100.0;
    end if;

end$$
create trigger before_products_update before update on products for each row
begin

	if new.value > 100.0 then
		set new.value := 100.0;
    end if;

end$$
set delimiter ;

insert into products (value) values (500);
update products set value = 102 where id=1;
select * from products;

# ----- 126 triggers and transactions ---------------------

show tables;

create table sales(id int primary key auto_increment, product varchar(45) not null, sold numeric(8,2) not null);

create table sales_totals(id int primary key auto_increment, total numeric(11,2) not null, day date);

alter table sales_totals add unique (day);

show index from sales_totals;


delimiter $$
create trigger before_sales_insert before insert on sales for each row
begin

	declare today date default date(now());
	declare count int default 0;

	select count(*) from sales_totals where day = today into count for update;
    					# raf: for update will lock entire table unless we have index on day comumn
    					# unique is by the way an index too - add unique (day); - so we ok here
    if count = 0 then
		insert into sales_totals (total, day) values (new.sold, today);
	else
		update sales_totals set total = total + new.sold where day = today;
	end if;

end$$
delimiter ;

drop trigger before_sales_insert;

select * from sales;
select * from sales_totals;

# START TRANSACTION;  Raf: this trigger runs in a single transaction by default
insert into sales (product, sold) values ("Dog Lead Deluxe", 10.00);
# COMMIT;

set sql_safe_updates=0;
delete from sales;
delete from sales_totals;

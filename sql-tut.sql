



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




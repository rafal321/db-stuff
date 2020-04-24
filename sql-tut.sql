



# -----------video 122-114 ----------------------------
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




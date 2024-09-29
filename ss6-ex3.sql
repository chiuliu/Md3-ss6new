create database transaction;
use transaction;

create table users (
	id int auto_increment primary key,
    name varchar(100) not null,
    myMoney double check (myMoney >= 0),
    address varchar(255) not null,
    phone varchar(11) unique not null,
    dateOfBirth date not null,
    status bit(1)
);

create table transfer (
	sender_id int not null,
    foreign key (sender_id) references users(id),
    receiver_id int not null,
    foreign key (receiver_id) references users(id),
    money double check (money >= 0),
    transfer_date datetime
);

insert into users(name, myMoney, address, phone , dateOfBirth, status) values
('Le Tiep',25000,'Bac Ninh','0333125999','1995-5-9',0),('Quang Tran',12000,'Gia Lam','0333111999','1995-1-1',1);
-- drop procedure transfer_money;
delimiter //
create procedure transfer_money(
	IN user_id_one int, 
    IN user_id_two int, 
    IN money_in double)
begin
	declare money double;
    select myMoney into money from users where id = user_id_one;
    start transaction;
    IF (money_in > money) 
			then rollback;
             signal sqlstate '45000' set message_text = 'Không có đủ tiền';
	else
		update users set myMoney = myMoney + money_in where id = user_id_two;
        update users set myMoney = myMoney - money_in where id = user_id_one;
        commit;
	end if;
end //
delimiter ;
call transfer_money(1,2,70000);
select * from users;
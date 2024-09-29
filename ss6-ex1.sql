create database shoppingcart;
use shoppingcart;

create table users (
	id int auto_increment primary key,
    name varchar(100) not null,
    address varchar(255) not null,
    phone varchar(11) unique not null,
    dateOfBirth date not null,
    status bit(1)
);

create table products (
	id int auto_increment primary key,
    name varchar(100) not null,
    price double check (price > 0) not null,
    stock int check (stock >= 0) not null,
    status bit(1)
);

create table shopping_cart (
	id int auto_increment primary key,
    user_id int not null,
    constraint fk_01 foreign key (user_id) references users(id),
    product_id int not null,
    constraint fk_02 foreign key (product_id) references products(id),
    quantity int check (quantity >= 0) not null,
    amount double not null
);
-- Tạo triggle khi thay đổi giá của sản phẩm thì amount của shopping_cart cũng phải cập nhật lại
delimiter //
create trigger update_amount 
	after update 
    on products
    for each row
    begin
		update shopping_cart as sc join products as p on sc.product_id = old.id set sc.amount = new.price * sc.quantity;
    end//
insert into products(name, price, stock, status) value ('mu adidas', 1200, 10, 1);
insert into users (name, address, phone, dateOfBirth, status) value ('Quang Tran','Gia Lam','0333111999','2024-1-1',1);
insert into shopping_cart(user_id, product_id, quantity, amount) value (1, 1, 3, 2400);
update products set price = 1300 where id = 1;
select * from shopping_cart;

# khi xoá product thì những dữ liệu ở bảng shopping_cart có chứa product bị xoá cũng phải xoá theo
DROP TRIGGER IF EXISTS delete_product;
delimiter //
create trigger delete_product
	after delete on products
    for each row
    begin
		delete from shopping_cart where product_id = old.id;
    end//
    delete from products where id = 3;
   --  alter table shopping_cart drop foreign key product_id;   
--     drop trigger before_update;
	
# Khi thêm 1 sản phẩm vào shopping_cart với số lượng n thì bên product cũng sẽ bị trừ đi n số lượng

delimiter //

create trigger before_update
before update on shopping_cart
for each row
begin
    -- Declare a variable to hold the stock quantity
    declare current_stock int;

    -- Get the current stock quantity for the product
    select stock into current_stock
    from products
    where id = old.product_id;

    -- Check if the updated quantity exceeds available stock
    if (new.quantity > old.quantity) and (current_stock - (new.quantity - old.quantity) < 0) then
        signal sqlstate '45000' set message_text = 'Vượt quá số lượng trong kho';
    end if;
end//
delimiter ;

delimiter //

create trigger after_update
after update on shopping_cart
for each row
begin
  if(new.quantity < old.quantity)
  then update products set stock = stock + (old.quantity - new.quantity);
  elseif (new.quantity > old.quantity)
  then update products set stock = stock - (new.quantity-old.quantity);
  end if;
end//
delimiter ;
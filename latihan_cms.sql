-- *command terminal* 

-- check version :
-- psql --version 

-- check service list :
-- brew services list

-- start service :
-- brew services start postgresql

-- stop service :
-- brew services stop postgresql

-- untuk login ke database :
-- psql --host=localhost --port=5432 --username=apipkurniawan --dbname=latihan_cms --password

-- untuk backup database :
-- pg_dump --host=localhost --port=5432 --dbname=latihan_cms --username=apipkurniawan --format=plain --file=/Users/apipkurniawan/downloads/backup.sql --password

-- untuk restore database :
-- psql --host=localhost --port=5432 --dbname=belajar_restore --username=apipkurniawan --password --file=/Users/apipkurniawan/downloads/backup.sql




select * from pg_tables where schemaname='public';

-- create table
create table products(
	id varchar(10) not null,
	name varchar(100) not null,
	description text,
	price int not null default 0,
	quantity int not null default 0,
	created_date TIMESTAMP not null default current_timestamp
);

create table admin(
	id serial not null, -- auto increment
	first_name varchar(100) not null,
	last_name varchar(100),
	primary key (id)
);

create table customer(
	id serial not null,
	email varchar(100) not null,
	first_name varchar(100) not null,
	last_name varchar(100),
	primary key (id),
	constraint unique_email unique (email) -- validation table - unique
);

create table whishlist(
	id serial not null,
	id_product varchar(10) not null,
	description text,
	primary key (id),
	constraint fk_whishlist_product foreign key (id_product) references products(id) -- table relation
);

create table wallet (
	id serial not null,
	id_customer int not null,
	balance int not null default 0,
	primary key (id),
	constraint wallet_customer_unique unique (id_customer),
	constraint fk_wallet_customer foreign key (id_customer) references customer (id)
);


-- delete column
alter table products 
drop column description;


-- rename column
alter table products 
rename column name to nama;


-- 
truncate products;


-- delete table
drop table products;


-- insert data
insert into products(id, name, price, quantity)
values ('P001', 'Mie Ayam', 10000, 10);

insert into products(id, name, description, price, quantity)
values ('P002', 'Mie Ayam', 'Mie ayam bakso tahu', 15000, 10);

insert into products(id, name, price, quantity, category)
values ('P006', 'Padang', 20000, 4, 'Makanan'),
       ('P007', 'Matcha', 8000, 5, 'Minuman'),
       ('P008', 'Thai tea', 5000, 3, 'Minuman');
       
insert into admin(first_name, last_name)
values ('apip', 'kurniawan'),
	   ('tata', 'alfian');
	   
insert into customer(email, first_name, last_name)
values ('apip@gmail.com', 'apip', 'kurniawan');

insert into whishlist(id_product, description)
values ('P004', 'somay kesukaan'),
	   ('P003', 'Bakso pagedangan kesukaan');

insert into wallet(id_customer, balance)
values (1, 100000);
       

-- get data       
select * from whishlist;
select * from products;
select * from admin;
select * from customer;
select * from wallet;

select p.id as Kode, p.price as Harga, p.description as Deskripsi from products as p;

select * from products where category = 'Makanan' or (quantity > 100 and price > 10000);

select * from products where name ilike '%ilo%';


-- sorting data
select * from products order by price asc, id desc;


-- limit 
select * from products limit 2;


-- numeric function
select price / 1000 as price_in_k from products;


-- string function
select id, lower(name), length(name), lower(description) from products;


-- datetime function
select id, extract(year from created_date), extract(month from created_date) from products;


-- flow control function
select id, category, 
	   case category
	   		when 'Makanan' then 'Enak'
	   		when 'Minuman' then 'Seger'
	   		else 'Apa itu?'
	   end as category_case
from products;

select id,
       price,
       case
       		when price <= 10000 then 'Murah'
       		when price <= 20000 then 'Mahal'
       		else 'Mahal banget'
       end as murah
from products;


-- agregate function
select count(id) from products;
select avg(price) from products;
select max(price) from products;
select min(price) from products;


-- grouping
select category, count(id) from products group by category;

select category,
	   avg(price) as "Rata-rata harga",
	   min(price) as "Harga terendah",
	   max(price) as "Harga tertinggi"
from products
group by category

select category,
	   avg(price) as "Rata-rata harga",
	   min(price) as "Harga terendah",
	   max(price) as "Harga tertinggi"
from products
group by category
having avg(price) >= 10000;


--delete row
delete from products where id='P001';


-- delete constraint
alter table customer
drop constraint unique_email;


-- add constraint
alter table customer
add constraint unique_email unique (email);

alter table products
add constraint quantity_check check (quantity >= 0);

alter table whishlist 
add constraint fk_whishlist_customer foreign key (id_customer) references customer(id);


-- add primary key
alter table products
add primary key (id);


-- create type
create type PRODUCT_CATEGORY as enum ('Makanan', 'Minuman', 'Lain-lain');


-- add column
alter table products
add column category PRODUCT_CATEGORY;

alter table products 
add column description text;

alter table whishlist 
add column id_customer int;


-- update column
update products
set category = 'Makanan'
where id='P005';

update products
set category = 'Makanan'
where id='P003';

update products
set category = 'Makanan'
where id='P004';

update products
set price = price + 5000
where id='P004';

update whishlist 
set id_customer = 1
where id = 4;


-- create sequence
create sequence contoh_sequence;

select nextval('contoh_sequence');
select currval('contoh_sequence');


-- create index => pencarian jadi lebih cepat
create index product_id_and_name_index on products(id, name); 
select * from products where id='P003' or name='Somay';

create index products_name_search on products using gin (to_tsvector('indonesian', name));
select * from products where name @@ to_tsquery('mie');
select * from products where name @@ to_tsquery('mie & bakso');
select * from products where name @@ to_tsquery('mie | somay');


-- pencarian menggunakan full text search
select * from products
where to_tsvector(name) @@ to_tsquery('bakso');


-- get available languages
select cfgname from pg_ts_config; 


-- join table
select c.email, p.id, p.name, w.description 
from whishlist w
	join products p on w.id_product = p.id 
	join customer c on c.id  = w.id_customer; 


-- transaction (commit) => data yg sudah diproses akan disimpan
start transaction;

insert into whishlist(id_product, description)
values ('P008', 'transaction 1');

insert into whishlist(id_product, description)
values ('P007', 'transaction 2');

insert into whishlist(id_product, description)
values ('P006', 'transaction 3');

commit;


-- transaction (rollback) => data yg sudah diproses tidak jadi disimpan
start transaction;

insert into whishlist(id_product, description)
values ('P008', 'rollback 1');

insert into whishlist(id_product, description)
values ('P007', 'rollback 2');

insert into whishlist(id_product, description)
values ('P006', 'rollback 3');

rollback;


-- locking => untuk menghindari RACE CONDIITON terhadap data yg diupdate
start transaction;

update products
set quantity = 4
where id='P005';

commit; -- lepas locking


-- locking manual
start transaction;

select * from products where id = 'P005' for update;


-- schema
select current_schema(); --check schema used

create schema contoh_schema; --create new schema

drop schema contoh_schema; --delete schema

set search_path to public; --pindah schema

create table contoh_schema.products(
	id varchar(10) not null,
	name varchar(100) not null,
	description text,
	price int not null default 0,
	quantity int not null default 0,
	created_date TIMESTAMP not null default current_timestamp
);

select * from contoh_schema.products;


-- user management database
create role apip;

create role tata;

drop role tata;

alter role apip login password 'rahasia';

alter role tata login password 'rahasia';

grant insert, update, select on all tables in schema public to apip; --hak akses DML table
grant usage, select, update on public.whishlist to apip; --hak akses DML sequence
grant insert, update, select on public.customer to tata; --hak akses DML sepesific table


-- restore database
-- warning: pastikan setelah backup database lakukan restore database
create database belajar_restore;




drop procedure if exists  whileProc1;
delimiter $$
create procedure whileProc1(in startnum int, in endnum int)
begin
	declare i int;
    declare hap int;
    set i = startnum;
    set hap = 0;
    while(i <= endnum) do
		set hap = hap + i;
        set i = i + 1;
	end while;
    select concat(startnum, '부터 ', endnum, '까지의 합 ==>') 범위, hap;
end $$
delimiter ;

call whileProc1(1, 100);

--
drop procedure if exists whileProc2;
delimiter $$
create procedure whileProc2(in startnum int, in endnum int)
begin
	declare i int;
    declare hap int;
    set i = startnum;
    set hap = 0;
    mywhile : while(i <= endnum) do
		if(i%4 = 0) then
			set i = i + 1;
            iterate mywhile;
        end if;
        set hap = hap + i;
        if(hap > 1000) then
			leave mywhile;
		end if;
        set i = i + 1;
	end while;
    SELECT hap;
end $$
delimiter ;
call whileProc2(1, 100);

drop table if exists gatetable;
create table gatetable(id int auto_increment primary key, entry_time datetime);

set @curdatetime = current_timestamp();

prepare myquery from 'insert into gatetable values(null, ?)';
execute myquery using @curdatetime;
execute myquery using @curdatetime;

select * from gatetable;
deallocate prepare myquery;

drop database if exists naver_db;
create database naver_db;
use naver_db;

drop table if exists member;
create table member(
	mem_id char(8) not null primary key,
    mem_name varchar(10) not null,
    mem_number tinyint not null,
    addr char(2) not null,
    phone1 char(3),
    phone2 char(8),
    height tinyint unsigned,
    debut_date date
);

drop table if exists buy;
create table buy(
	num int auto_increment not null primary key,
    mem_id char(8) not null,
    prod_name char(6) not null,
    group_name char(4),
    price int unsigned not null,
    amount smallint unsigned not null
);

show create table buy;

alter table buy drop foreign key buy_ibfk_2;

alter table buy
	add constraint
	foreign key(mem_id) references member(mem_id)
    on update cascade on delete cascade;

insert into member values('TWC', '트와이스', 9, '서울', '02', '11111111', 167, '2015-10-19');
insert into member values('BLK', '블랙핑크', 4, '경남', '055', '22222222', 163, '2016-08-08');
insert into member values('WMN', '여자친구', 6, '경기', '031', '33333333', 166, '2015-01-15');

insert into buy(mem_id, prod_name, group_name, price, amount) values('TWC', '지갑', null, 30, 2);
insert into buy(mem_id, prod_name, group_name, price, amount) values('BLK', '맥북프로', '디지털', 30, 2);
insert into buy(mem_id, prod_name, group_name, price, amount) values('apn', '아이폰', '디지털', 30, 2);
select * from buy;

update member set mem_id = 'pink' where mem_id = 'TWC';
select * from buy;

## 5장 확인문제 13
select * from information_schema.tables where table_schema = 'market_db';

## 15
use market_db;
show tables from world;

show full tables;

drop view v_height;
drop view v_member;
drop view v_memberbuy;

create view v_member 
as select mem_id, mem_name addr from member;

select * from v_member;

create or replace view v_member
as select mem_id, mem_name, addr from member;

desc v_member;
update v_member set addr ='부산' where mem_id = 'blk';


## 7장
drop procedure if exists user_proc;
delimiter $$
create procedure user_proc(in usernumber int, in userheight int)
begin
	select * from member where mem_number >= usernumber and height >= userheight;
end $$
delimiter ;

call user_proc(6, 165);

-- 1
drop procedure if exists user_proc3;
delimiter $$
create procedure user_proc3(in usertxt varchar(10), out outvalue int)
begin
	insert into test values(null, usertxt);
    select max(no) into outvalue from test;
end $$
delimiter ;

-- 2
drop table if exists test;
create table test(no int auto_increment primary key, txt char(10));

call user_proc3('안녕', @a);
select @a;

-- 3
drop procedure if exists pro;
delimiter $$
create procedure pro(in num int, out result int)
begin
	declare i, hap int;
    set i = num, hap = 1;
    while(i > 0) do
		set hap = hap * i;
		set i = i - 1;
	end while;
    select hap into result;
end $$
delimiter ;

call pro(5, @result);
select @result;

-- 동적 sql
drop procedure if exists dynamic_proc1;
delimiter $$
create procedure dynamic_proc1(in tablename varchar(20))
begin
	set @sql = concat('select count(*) as count from ', tablename);
    prepare myquery from @sql;
    execute myquery;
    deallocate prepare myquery;
end $$
delimiter ;

call dynamic_proc1('member');

select * from city;

-- 1
drop procedure if exists myProc;
delimiter $$
create procedure myProc(in ccode varchar(20), in ccity varchar(20))
begin
	select * from city where countrycode = ccode and district = ccity;
end $$
delimiter ;

call myProc('usa', 'california');

select * from country;
select * from city;
-- 2
drop procedure if exists myProc2;
delimiter $$
create procedure myProc2(in name1 varchar(20))
begin
	declare pop int;
    select population into pop from country where name = name1;
    if(pop is null) then
		select population into pop from city where name = name1;
	end if;
    if(pop is null) then
		select '테이블 x' as result;
	else 
		select pop as result;
	end if;
end $$
delimiter ;

call myProc2('south korea');
call myProc2('pusan');
call myProc2('propop');

-- 3
drop function if exists myFunc;
delimiter $$
create function myFunc(n bigint unsigned)
returns int unsigned
deterministic
begin
	return n / 16384;
end $$
delimiter ;

select table_name, myFunc(data_length) 데이터페이지수 from information_schema.tables where table_schema = 'world';

-- 확인문제 1
drop procedure if exists pro2;
delimiter $$
create procedure pro2(in dbname varchar(20), in tablename varchar(20))
begin
	set @sql = concat('show index from ', dbname, '.', tablename);
    prepare myquery from @sql;
    execute myquery;
    deallocate prepare myquery;
end $$
delimiter ;

call pro2('market_db', 'buy');
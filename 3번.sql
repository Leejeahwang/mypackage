-- 4장. 스튜어드 프로시저
delimiter $$
create procedure ifProc1()
begin
	if((select count(*) from member) >= 10) then
		select '회원수는 10 이상입니다.' as '답변';
	else select '회원수는 10 미만입니다.' as '답변';
    end if;
end $$
delimiter ;

call ifProc1();

drop procedure if exists ifProc2;
delimiter $$
create procedure ifProc2(in singerId char(8))
begin
	declare ddate date;
    declare days int;
    select debut_date into ddate from member where mem_id = singerId;
    set days = datediff(current_date(), ddate);
    if(days > 7*365) then
		select concat(singerId, '는 데뷔한 지', days, ' 일. respect!!') as 기간;
	else 
		select concat(singerId, '는 데뷔한 지', days, ' 일. 아직 재계약 전') as 기간;
	end if;
end $$
delimiter ;

call ifProc2('ITZ');


drop procedure if exists whileProc1;
delimiter $$
create procedure whileProc1(in startNum INT, IN endNum INT)
begin
	declare i int;
    declare hap int;
    set i = startNum;
    set hap = 0;
    while(i <= endNum) do
		set hap = hap + i;
        set i = i + 1;
	end while;
    select concat(startNum, '부터 ', endNum, '까지의 합 --> ') 범위, hap;
end $$;
delimiter ;

call whileProc1(1, 100);

drop procedure if exists whileProc2;
delimiter $$
create procedure whileProc2(in startnum int, in endnum int)
begin
	declare i int;
    declare hap int;
    set i = startnum;
    set hap = 0;
    mywhile: while(i <= endnum) do
		if(i%4 = 0) then
			set i = i + 1;
            iterate mywhile;
		end if;
        set hap = hap + i;
        if (hap > 1000) then
			leave mywhile;
		end if;
        set i = i + 1;
	end while;
    select concat(startnum, '부터 ', endnum, '까지의 합(4의 배수 제외), 1000 넘으면 종료 ---> ') 범위, hap;
end$$
delimiter ;

call whileProc2(1,100);

drop table if exists gatetable;
create table gatetable(id int auto_increment primary key, entry_time datetime);
set @curdatetime = current_timestamp();

prepare myquery from 'insert into gatetable values(null, ?)';
execute myquery using @curdatetime;
execute myquery using @curdatetime;

select * from gatetable;
deallocate prepare myquery;

-- 5장
create database test;
use test;
create table table4(
	a char(5) not null,
    b char(5) not null,
    c char(5),
    primary key(a, b) ## 이거는 된데
);
## primary key는 한 테이블 당 한개

## create 이후에 primary key 설정
drop table if exists member;
create table member(
	mem_id char(8) not null,
    mem_name varchar(10) not null,
    height tinyint unsigned null
);

alter table member
	add constraint
    primary key(mem_id);
    
drop table if exists buy, member;
create table member(
	mem_id char(8) not null primary key,
    mem_name varchar(10) not null,
    height tinyint unsigned null
);

create table buy(
	num int auto_increment not null primary key,
    mem_id char(8) not null,
    prod_name char(6) not null,
    foreign key(mem_id) references member(mem_id)
);

drop table if exists buy;
create table buy(
	num int auto_increment not null primary key,
    mem_id char(8) not null,
    prod_name char(6) not null
);
alter table buy
	add constraint
    foreign key(mem_id)
    references member(mem_id);
    
## 기본키-외래키 설정된 상태에서 회원아이디 변경하려고 하면 
-- 1. update member set mem_id = 'pink' where mem_id = 'blk';
-- 이 문장은 mem_id='blk' 값을 'pink'로 변경하겠다는 의미.

-- 그런데 이 blk라는 값이 다른 테이블에서 외래키로 참조되고 있으면, 외래키 제약조건 때문에 값을 바꿀 수 없음.

-- ❌ 오류 발생 이유: 참조 무결성 제약조건 위반.

-- 2. delete from member where mem_id = 'blk';
-- 이 문장은 mem_id='blk'인 회원을 삭제하겠다는 의미.

-- 그런데 이 회원이 외래키로 다른 테이블에서 참조되고 있으면, 삭제 시에도 참조 무결성 위반 오류가 발생함.

-- ❌ 오류 발생 이유: 해당 멤버가 다른 테이블에서 참조되고 있어 삭제할 수 없음.

drop table if exists buy;
create table buy(
	num int auto_increment not null primary key,
    mem_id char(8) not null,
    prod_name char(6) not null
);
alter table buy
	add constraint
    foreign key(mem_id) references member(mem_id)
    on update cascade
    on delete cascade;
    
drop table if exists buy, member;
create table member(
	mem_id char(8) not null primary key,
    mem_name varchar(10) not null,
    height tinyint unsigned null,
    email char(30) null unique
);

drop table if exists member;
create table member(
	mem_id char(8) not null primary key,
    mem_name varchar(10) not null,
    height tinyint unsigned null check (height >= 100),
    phone1 char(3) null
);

alter table member
	add constraint
    check(phone1 in ('02', '031', '032'));
    
drop table if exists member;
create table member(
	mem_id char(8) not null primary key,
    mem_name varchar(10) not null,
    height tinyint unsigned null default 160,
    phone1 char(3) null
);

insert into member values('spc', '우주소녀', default, default);
select * from member;

use market_db;
create view v_member
as
select mem_id, mem_name, addr from member;

select * from v_member;

create view v_memberbuy
as
select B.mem_id, M.mem_name, B.prod_name, M.addr, concat(M.phone1, M.phone2) 연락처
from buy B
	inner join member M
    on B.mem_id = M.mem_id;
    
select * from v_memberbuy where mem_name = '블랙핑크';

desc v_member;
show create view v_member;

update v_member set addr = '부산' where mem_id = 'blk'; -- delete도 가능
select * from member where mem_id = 'blk'; -- 뷰를 통해서 update 가능, 
insert into v_member values('bts', '방탄', '경기'); -- error, not null 이 있는 컬럼이 있기에
-- 뷰가 있는 상태에서 원본 테이블 삭제 가능, 그후 뷰에 접근 시에 오


-- 확인문제 11
-- 예를 들어 테이블명이 exam이라면
ALTER TABLE usertable MODIFY COLUMN regyear SMALLINT;

ALTER TABLE 테이블명 CHANGE COLUMN email mail VARCHAR(100);
ALTER TABLE 테이블명 CHANGE COLUMN mail email VARCHAR(100);

alter table usertable add column phone varchar(20);
alter table usertable drop column phone;

rename table usertable to users;
alter table usertable rename to users;

rename table users to usertable;
alter table users rename to usertable;

-- 13, 14
SELECT *
FROM information_schema.views
WHERE table_schema = 'market_db';

-- 15
use market_db;
show tables;

show tables from world;

-- 16
show full tables;

-- 18

create or replace view v_height
as
select * from member where height >= 167; -- with check option 사용하면 인서트 함부로 x

select * from v_height;
select * from member;
delete from v_height where height < 167;

insert into v_height values('s', 's', 1, 's', '01', '44444444', '165', '2002-11-02'); -- 실행은 되는데 뷰에는 없음

-- 20
create table city(
	id int auto_increment not null,
    name char(35) not null,
    primary key(id)
);
insert into city(select id, name from world.city);

create table city1 (select id, name from world.city);

select * from information_schema.tables where table_schema = 'naver_db';
show table status from naver_db;

-- 21
-- row_format 으로 공간절-- 6장
show table status like 'member';
create index idx_member_addr on member(addr);
show index from member;

analyze table member;
show table status like 'member';

create unique index idx_member_mem_name on member (mem_name);
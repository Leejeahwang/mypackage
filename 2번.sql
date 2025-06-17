
DROP DATABASE IF EXISTS market_db; -- 만약 market_db가 존재하면 우선 삭제
CREATE DATABASE market_db;
USE market_db; -- 사용할 데이터베이스를 지정 또는 변경할 때

CREATE TABLE member -- 회원 테이블
( mem_id  		CHAR(8) NOT NULL PRIMARY KEY, 
  mem_name    	VARCHAR(10) NOT NULL, -- 멤버명
  mem_number    INT NOT NULL,  -- 멤버 수
  addr	  		CHAR(2) NOT NULL, -- 서울, 부산 등
  phone1		CHAR(3), -- 국번(02, 051 등)
  phone2		CHAR(8), -- 나머지 폰번호(하이픈제외)
  height    	SMALLINT,  -- 평균 키
  debut_date	DATE  -- 데뷔일
);

CREATE TABLE buy -- 구매 테이블
(  num 		INT AUTO_INCREMENT NOT NULL PRIMARY KEY, -- 구매번호 
   mem_id  	CHAR(8) NOT NULL, -- 외래키
   prod_name 	CHAR(6) NOT NULL, -- 제품명
   group_name 	CHAR(4)  , -- 제품분류
   price     	INT  NOT NULL, -- 가격
   amount    	SMALLINT  NOT NULL, -- 수량
   FOREIGN KEY (mem_id) REFERENCES member(mem_id)
);

INSERT INTO member VALUES('TWC', '트와이스', 9, '서울', '02', '11111111', 167, '2015.10.19');
INSERT INTO member VALUES('BLK', '블랙핑크', 4, '경남', '055', '22222222', 163, '2016.08.08');
INSERT INTO member VALUES('WMN', '여자친구', 6, '경기', '031', '33333333', 166, '2015.01.15');
INSERT INTO member VALUES('OMY', '오마이걸', 7, '서울', NULL, NULL, 160, '2015.04.21');
INSERT INTO member VALUES('GRL', '소녀시대', 8, '서울', '02', '44444444', 168, '2007.08.02');
INSERT INTO member VALUES('ITZ', '잇지', 5, '경남', NULL, NULL, 167, '2019.02.12');
INSERT INTO member VALUES('RED', '레드벨벳', 4, '경북', '054', '55555555', 161, '2014.08.01');
INSERT INTO member VALUES('APN', '에이핑크', 6, '경기', '031', '77777777', 164, '2011.02.10');
INSERT INTO member VALUES('SPC', '우주소녀', 13, '서울', '02', '88888888', 162, '2016.02.25');
INSERT INTO member VALUES('MMU', '마마무', 4, '전남', '061', '99999999', 165, '2014.06.19');

INSERT INTO buy VALUES(NULL, 'BLK', '지갑', NULL, 30, 2);
INSERT INTO buy VALUES(NULL, 'BLK', '맥북프로', '디지털', 1000, 1);
INSERT INTO buy VALUES(NULL, 'APN', '아이폰', '디지털', 200, 1);
INSERT INTO buy VALUES(NULL, 'MMU', '아이폰', '디지털', 200, 5);
INSERT INTO buy VALUES(NULL, 'BLK', '청바지', '패션', 50, 3);
INSERT INTO buy VALUES(NULL, 'MMU', '에어팟', '디지털', 80, 10);
INSERT INTO buy VALUES(NULL, 'GRL', '혼공SQL', '서적', 15, 5);
INSERT INTO buy VALUES(NULL, 'APN', '혼공SQL', '서적', 15, 2);
INSERT INTO buy VALUES(NULL, 'APN', '청바지', '패션', 50, 1);
INSERT INTO buy VALUES(NULL, 'MMU', '지갑', NULL, 30, 1);
INSERT INTO buy VALUES(NULL, 'APN', '혼공SQL', '서적', 15, 1);
INSERT INTO buy VALUES(NULL, 'MMU', '지갑', NULL, 30, 4);

SELECT * FROM member;
SELECT * FROM buy;

drop table buy;

alter table member drop primary key;


show index from member;
show table status like 'member';
create index idx_member_addr on member(addr);
analyze table member;

create unique index idx_member_mem_number on member(mem_number); ## mem_number에는 중복된 데이터가 있기에 고유키 생성시 오류 발생
create unique index idx_member_mem_name on member(mem_name); ## 이러면 이름이 동일한 회원 못들어옴

select * from member;
select * from member where mem_name = '블랙핑크';

drop index idx_member_addr on member;
drop index idx_member_mem_number on member;
drop index idx_member_mem_name on member;

alter table buy drop foreign key buy_ibfk_1;
alter table member drop primary key;


## 7장. 스토어드 프로시저
DROP PROCEDURE IF EXISTS pro;
DELIMITER $$
CREATE PROCEDURE pro(IN mid char(8), IN mname varchar(10))
BEGIN
	update member
    set mem_name = mname
    where mem_id = mid;
END $$
DELIMITER ;

call pro('BLK', '블랙로즈');
select * from member;

DROP PROCEDURE IF EXISTS user_proc3;
DELIMITER $$
CREATE PROCEDURE user_proc3(IN usertxt VARCHAR(10), OUT outvalue INT)
BEGIN
	INSERT INTO test VALUES (NULL, usertxt);
	SELECT MAX(no) INTO outvalue FROM test;
END $$
DELIMITER ;

DROP TABLE IF EXISTS test;
CREATE TABLE test (no INT AUTO_INCREMENT PRIMARY KEY, txt CHAR(10));

CALL user_proc3('안녕?', @a);
CALL user_proc3('집?', @a);
SELECT @a;
select * from test;


DROP PROCEDURE IF EXISTS user_proc4;
DELIMITER $$
CREATE PROCEDURE user_proc4(IN username VARCHAR(10))
BEGIN
	declare dyear int;
	SELECT YEAR(debut_date) INTO dyear FROM member WHERE mem_name = username;
	IF (dyear>=2018) THEN
		SELECT '아직 신인' as 메세지;	
	else
		SELECT '계속 팬할게요' AS 메세지;
	end if;
end $$
DELIMITER ;

CALL user_proc4('잇지');

DROP PROCEDURE IF EXISTS while_proc;
DELIMITER $$
CREATE PROCEDURE while_proc(IN usernum INT)
BEGIN
	DECLARE hap, i INT;
	SET hap = 0, i = 1;
	WHILE (i <= usernum) DO
		if (i % 5 != 0) then
			set hap = hap + i;
		end if;
		set i = i + 1;
	END WHILE;
	SELECT hap AS 합계;
END $$
DELIMITER ;
CALL while_proc(10);



## 과제 1
DROP PROCEDURE IF EXISTS pro;
DELIMITER $$
CREATE PROCEDURE pro(IN num INT, OUT result INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    SET result = 1;

    WHILE i <= num DO
        SET result = result * i;
        SET i = i + 1;
    END WHILE;
END$$
DELIMITER ;

call pro(5, @result);
select @result;

## 과제 2
drop procedure if exists pro2;
delimiter $$
create procedure pro2(in db_name varchar(10), in tb_name varchar(10))
begin
	set @sql = concat('select * from ', db_name, '.', tb_name);
	prepare stmt from @sql;
    execute stmt;
    deallocate prepare stmt;
end$$
delimiter ;

call pro2('market_db','buy');
call pro2('world', 'city');

DROP FUNCTION IF EXISTS calculate_age;
DELIMITER $$
CREATE FUNCTION calculate_age(bdate date)
RETURNS INT
DETERMINISTIC
BEGIN
RETURN YEAR(CURDATE()) - year(bdate);
END$$
DELIMITER ;
SELECT mem_name, debut_date, calculate_age(debut_date) 연차 from member;

## 확인문제
## 1
use world;
show tables;

desc city;
select * from city;
desc country;

drop procedure if exists myProc;
delimiter $$
create procedure myProc(in code char(3), in dis char(20))
begin
	select * from city where countrycode = code and district = dis limit 4;
end $$
delimiter ;
call myProc('usa', 'california');

## 2
DROP PROCEDURE IF EXISTS myProc2;
DELIMITER $$

CREATE PROCEDURE myProc2(IN pname CHAR(35))
BEGIN
    DECLARE cpop INT DEFAULT NULL;
    DECLARE ctypop INT DEFAULT NULL;

    -- 1. 국가명 조회
    SELECT population INTO cpop
    FROM country
    WHERE name = pname;

    -- 2. 국가가 존재하면 출력
    IF cpop IS NOT NULL THEN
        SELECT FORMAT(cpop, 0) AS result;

    ELSE
        -- 3. 국가가 없으면 도시명 조회
        SELECT population INTO ctypop
        FROM city
        WHERE name = pname;

        -- 4. 도시가 존재하면 출력
        IF ctypop IS NOT NULL THEN
            SELECT FORMAT(ctypop, 0) AS result;
        ELSE
            -- 5. 국가도 도시도 아닐 때
            SELECT '테이블에 없는 국가명(도시명)입니다.' AS result;
        END IF;
    END IF;
END$$

DELIMITER ;

call myProc2('south korea');
call myProc2('pusan');
call myProc2('prprpr');

## 3
use world;
show tables;

desc city;
select * from city;
desc country;

DROP FUNCTION IF EXISTS myFunc;
DELIMITER $$
CREATE FUNCTION myFunc(data_length BIGINT)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN CEIL(data_length / 1024);
END$$

DELIMITER ;

drop function if exists myfunc;
DELIMITER $$
create function myfunc(n bigint unsigned) 
returns int unsigned  -- 여기도 딱히 언급없으면  int해도 되지만 음수일 가능성 없으므로 이왕이면 int unsined 
deterministic
begin
    return n / 16384;   -- 한 페이지가 16KB이므로 전체 바이트수 나누기 16384
end $$
DELIMITER ;

SELECT table_name,
       myFunc(data_length) AS '데이터페이지수'
FROM information_schema.tables
WHERE table_schema = 'world';
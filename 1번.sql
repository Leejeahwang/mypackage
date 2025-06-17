-- 6장 확인문제
-- 1
-- 클러스터형 인덱스(ex. pk) pk설정 시 자동으로 클러스터 인덱스됨, 클러스터형 인덱스는 고유 인덱스에 속한다.
-- 보조인덱스는 클러스터형 인덱스 제외한 거 전부, unique설정 시 자동으로 보조 인덱스
-- unique로 설정된 보조인덱스는 고유 인덱스
-- 고유인덱스인지 아닌지 판단하려면 show index해서 non unique가 1인지 0인지 확인하면됨

-- (1) 클러스터 인덱스 
-- 생성 기준 : PK -> not null unique --> 내부관리, 고유인덱스 맞음(아니라고 하시는 분도 있다.)
-- 클러스터 인덱스도 B-tree 1개인데, leaf page에는 실제 데이터가 들어있음, leaf를 제외한 page들은 실제 data 아님(키 + 주소)로 구성
-- (2) 보조 인덱스
-- 생성 기준 : 자동으로 생성되는 건 column에 unique설정 했을 때 --> 고유 인덱스, 그리고 수동으로 create index할 수 있음
-- 고유 인덱스도 있고 비고유인덱스도 있음. show index 해보면 Non-unique가 0이면 고유 인덱스alter
-- 보조 인덱스 1개 설정할 때마다 B-tree 1개씩 생깁니다.
-- 보조인덱스의 leaf 페이지에는 실 데이터 위치가 저장됩니다.

-- 2
use market_db;
show index from member;

show index from market_db.member;

-- 3
-- 장점 : select 빠르게 하려고 

drop table if exists test;

create table test(a int not null unique, b char(10));

insert into test values(100, '철수');
insert into test values(300, '영희');
insert into test values(200, '둘리');

select * from test;
show index from test;

show table status;
show table status like 'member';

-- 현재 pk만 있는 member 테이블에 고유보조 1ㅐㄱ, 단순보조 1개 인덱스 만든 후, 인덱스 페이지가 몇 개인지 확인
show index from member;
-- 2개 인덱스 수동 생성
create unique index idx_member_mem_name on member(mem_name);
create index idx_member_addr on member(addr);

analyze table member;
show table status like 'member';

-- select 실행 후에 실행 계획을 확인할 수 있다. MySQL이 우리한테 보고하는거. "이런 게획에 기반하여 select를 수행했습니다."
-- "실제로 이렇게 select 했습니다." 와는 다름(돌발변수에 의해서 계획과는 다르게 실행했을 가능성 있음)
-- 계획은 두가지, 

select table_name, constraint_name
from information_schema.referential_constraints
where constraint_schema='market_db'
and referenced_table_name='member';

-- member 테이블의 모든 인덱스 다 삭제
-- 1. 일단 형황 파악
show index from member;

-- 보조 인덱스부터 삭제
drop index idx_mem_addr on member;
drop index idx_member_mem_name on member;
-- 보조 인덱스 다 삭제 후, primary index 삭제
alter table member drop primary key; -- 외래키 오류 뜸

-- fk오류가 나는 경우 도대체 누가 나를 보고 있나 확인
select table_name, constraint_name
from information_schema.referential_constraints
where constraint_schema='market_db'
and referenced_table_name='member';

alter table buy drop foreign key buy_ibfk_1;

-- pk날려도 데이터페이지 재정렬하거나 하지 않ㅇ므, 하지만 새로운 데이터 insert되면 이제부터는 insert순서

-- fk 있어서 pk 제거 못하니깐 일단 buy table 제거
drop table buy;
-- 그 다음 member table 인덱스 상황 일단 살펴보고 
show index from member;
analyze table member;
show table status like 'member'; # 데이터도 있고 보조인덱스도 있음을 알 수 있다.

-- 그 다음 pk 제거
alter table member drop primary key;
-- pk 없이 데이터는 어떤 순으로 있을까나? 
select * from member;

-- 확인문제 5
create table second(
	mem_id char(8),
    mem_name varchar(10)
);
alter table second add constraint unique(mem_name);
insert into second values ('TWC', '트와이스');
insert into second values ('BLK', '블랙핑크');
insert into second values ('WHN', '여자친구');
insert into second values ('OMY', '오마이걸');
insert into second values ('GRL', '소녀시대');
insert into second values ('ITZ', '잇지');
insert into second values ('RED', '레드벨벳');

insert into second values ('APN', '에이핑크');
insert into second values ('SPC', '우주소녀');
insert into second values ('MMU', '마마무');

select * from second;


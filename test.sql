create database StudentManagement;
use StudentManagement;

create table students(
	student_id varchar(5) primary key,
    full_name varchar(50) not null,
    total_debt decimal(10,2) default 0
);

create table subjects(
	subject_id varchar(5) primary key,
    subject_name varchar(50) not null,
    credits int check(credits > 0)
);

create table grades(
	student_id varchar(5),
    subject_id varchar(5),
    score decimal(4,2) check(score between 0 and 10),
    primary key(student_id, subject_id),
    foreign key(student_id) references students(student_id),
    foreign key(subject_id) references subjects(subject_id)
);

create table grade_log(
	log_id int auto_increment primary key,
    student_id varchar(5),
    old_score decimal(4,2),
    new_score decimal(4,2),
    changed_date datetime default current_timestamp,
    foreign key(student_id) references students(student_id)
);

insert into students(student_id, full_name, total_debt)
value	('S001', 'Nguyen Van A', 2000000),
		('S002', 'Tran Thi B', 1500000),
        ('S003', 'Le Van C', 0);


insert into subjects(subject_id, subject_name, credits)
value	('SUB01', 'Co so du lieu', 3),
		('SUB02', 'Lap trinh Python', 4),
        ('SUB03', 'Mang may tinh', 2);


insert into grades(student_id, subject_id, score)
value	('SV01', 'SUB01', 8.5),
		('S001', 'SUB02', 7.0),
        ('S002', 'SUB01', 9.0),
        ('S002', 'SUB03', 6.5),
        ('S003', 'SUB02', 8.0);


insert into grade_log(student_id, old_score, new_score)
value	('S001', 7.0, 8.5),
		('S002', 5.5, 6.5),
        ('S003', 7.5, 8.0);

-- Câu 1 (Trigger - 20đ): Nhà trường yêu cầu điểm số (score) nhập vào hệ thống 
-- phải luôn hợp ợp lệ (từ từ 0 đến 10). Hãy viết một TrTrigger có tên tg_check_scorechạy 
-- trước khi thêm (BEFORE INSERTRT) dữ dữ liệu vào bảng grades.
-- Nếu người dùdùng nhập score < 0 thì tự động gán về 0.
-- Nếu người dùdùng nhập score > 10 thì tự động gán về 10.
Delimiter //
create trigger tg_check_score
before insert on grades
for each row 

begin
	if new.score < 0 then
		set new.score = 0;
	end if;
    
    if new.score > 10 then
		set new.score = 10;
	end if;
end //
Delimiter ;

-- Câu 2 (TrTransaction - 20đ): Viết một đoạn script sử dụng Transaction để thêm một sinh viên mới. 
-- Yêu cầu đảm bảo tính trọn vẹn "All or Nothing" của dữ liệu:

start transaction;
	insert into students(student_id, full_name)
    value 	('SV02', 'Ha Bich Ngoc');
    
    update students
    set total_debt = 5000000
    where student_id = 'SV02';
commit;

-- Câu 3 (Trigger - 15đ): Để chống tiêu cực trong thi cử, mọi hành động sửa đổiđiểm số cần được ghi lại. 
-- Hãy viết Trigger tên tg_log_grade_upupdate chạy saukhkhi cập ập nhật (AFTER UPDATATE) trên bảng grades.

Delimiter //
create trigger tg_log_grade_update
after update on grades
for each row

begin
	insert into grade_log(student_id, old_score, new_score)
    value	(old.student_id, old.score, new.score);
end //
Delimiter ;


-- Câu 4 (Transaction & Procedure cơ bản - 15đ): Viết một Stored Procedure đơn giản tên sp_pay_tuition 
-- thực hiện việc đóng học phí cho sinh viên 'SV01'với số tiền 2,000,000.

Delimiter //
create procedure sp_pay_tuition()

begin
	declare money decimal(10,2);
    
    select total_debt into money
    from students
    where student_id = 'SV01';
    
    start transaction;
		set money = money - 2000000;
        
        if money < 0 then
			rollback;
		else 
			commit;
		end if;
end //
Delimiter ;












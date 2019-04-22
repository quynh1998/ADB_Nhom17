create database nv
use nv
go
CREATE TABLE SINHVIEN
(
	MASV NVARCHAR(20),
	HOTEN NVARCHAR(100) NOT NULL,
	NGAYSINH DATETIME,
	DIACHI NVARCHAR(200),
	MALOP VARCHAR(20),
	TENDN NVARCHAR(100) NOT NULL,
	MATKHAU VARBINARY(MAX) NOT NULL,
	CONSTRAINT PK_MASV PRIMARY KEY (MASV)
)
CREATE TABLE NHANVIEN
(
	MANV VARCHAR(20),
	HOTEN NVARCHAR(100) NOT NULL,
	EMAIL VARCHAR(20),
	LUONG VARBINARY(MAX) NOT NULL ,
	TENDN NVARCHAR(100) NOT NULL,
	MATKHAU VARBINARY(MAX) NOT NULL,
	CONSTRAINT PK_MANV PRIMARY KEY (MANV)
)

go
create proc SP_INS_SINHVIEN (@masv nvarchar(20),@hoten nvarchar(100),@ngaysinh datetime,@diachi nvarchar(200),@malop varchar(20),@tendn nvarchar(100),@matkhau varbinary(max))
as
begin
	IF NOT EXISTS (SELECT TENDN FROM NHANVIEN WHERE TENDN=@tendn)
	insert into SINHVIEN(MASV,HOTEN,NGAYSINH,DIACHI,MALOP,TENDN,MATKHAU) values
	(@masv,@hoten,@ngaysinh,@diachi,@malop,@tendn,hashbytes('md5',convert(varbinary,@matkhau)))
end


EXEC SP_INS_SINHVIEN 'SV01', 'NGUYEN VAN A', '1/1/1990', '280 AN
DUONG VUONG', 'CNTT-K35', 'NVA', 123456

DROP PROC SP_INS_SINHVIEN

SELECT * FROM SINHVIEN

go
--ii__AES 256

--use master
--b1
SELECT * FROM sys.symmetric_keys WHERE name LIKE '%MS_DatabaseMasterKey%'

--create master key
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '123';

drop master key
--create certificate 
CREATE CERTIFICATE nv WITH SUBJECT = 'NV Certificate';

DROP CERTIFICATE nv  

--Verify Certificate
SELECT * FROM sys.certificates where [name] = 'nv'


GO
--CREATE SYMMETRIC KEY
CREATE SYMMETRIC KEY insertnv  
WITH ALGORITHM = AES_256,  
IDENTITY_VALUE = '4201104129'  
ENCRYPTION BY CERTIFICATE nv;    

drop symmetric key insertnv

--open symmetric key
OPEN SYMMETRIC KEY insertnv DECRYPTION BY CERTIFICATE nv


CREATE PROC SP_INS_NHANVIEN (@manv varchar(20),@hoten nvarchar(100),@email varchar(20),@luong varbinary(max),@tendn nvarchar(100),@matkhau varbinary(max))
as
begin
	IF NOT EXISTS (SELECT TENDN FROM NHANVIEN WHERE TENDN=@tendn)
	INSERT INTO NHANVIEN VALUES
	(@Manv,@Hoten,@email,ENCRYPTBYKEY(Key_GUID('insertnv'),CONVERT(varbinary,@luong)),@tendn,HashBytes('sha1',CONVERT(varbinary,@matkhau)))

end

EXEC SP_INS_NHANVIEN 'NV01', 'NGUYEN VAN A', 'NVA@', 3000000,'NVA', 123

drop proc SP_INS_NHANVIEN

SELECT * FROM NHANVIEN
CLOSE SYMMETRIC KEY insertnv;

--iii
CREATE PROC SP_SEL_NHANVIEN
AS
BEGIN
	SELECT MANV,HOTEN,EMAIL,
	CONVERT(varbinary, DecryptByKey(LUONG)) AS LUONGCB
	FROM NHANVIEN
END

EXEC SP_SEL_NHANVIEN

DROP PROC SP_SEL_NHANVIEN
CLOSE SYMMETRIC KEY insertnv;

--test thu

CREATE PROC test 
(
	@manv varchar(20),
	@hoten nvarchar(100),
	@email varchar(20),
	@luong int,
	@tendn nvarchar(100),
	@matkhau varchar(20))
as
begin
	IF NOT EXISTS (SELECT TENDN FROM NHANVIEN WHERE TENDN=@tendn)
	INSERT INTO NHANVIEN VALUES
	(@Manv,@Hoten,@email,ENCRYPTBYKEY(Key_GUID('insertnv'),CONVERT(varbinary,@luong)),@tendn,HashBytes('sha1',CONVERT(varbinary,@matkhau)))

end

EXEC test 'NV01', 'NGUYEN VAN A', 'NVA@', 3000000,'NVA', 'abc123'

select * from NHANVIEN

CREATE PROC takenv
AS
BEGIN
	SELECT MANV,HOTEN,EMAIL,
	CONVERT(varchar(max), LUONG) AS LUONGCB
	FROM NHANVIEN
END

EXEC takenv
DROP PROC takenv

select cast(LUONG as varchar(max)) FROM NHANVIEN

--chuyển từ varbinary sang varchar
declare @b varbinary(max)
set @b = 0x5468697320697320612074657374

select cast(@b as varchar(max)) /*Returns "This is a test"*/
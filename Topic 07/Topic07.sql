-- HOÀNG PHƯỚC NGUYÊN
-- 20127258

GO 
USE QLDT 
GO 

/*J. Xuất ra toàn bộ danh sách giáo viên */
CREATE PROC SP_XUATTOANBO
    AS BEGIN 
        SELECT * FROM GIAOVIEN
    END 

EXEC SP_XUATTOANBO
DROP PROCEDURE SP_XUATTOANBO

/* k. Tính số lượng đề tài mà một giáo viên đang thực hiện */
GO
CREATE PROC SP_DEMDETAI @MAGV VARCHAR(9)
    AS BEGIN
        DECLARE @SODT INT
        SET @SODT = (SELECT COUNT(DISTINCT MADT)
                    FROM THAMGIADT
                    WHERE @MAGV = MAGV 
                    GROUP BY MAGV)
        PRINT N'Số lượng đề tài giáo viên mà giáo viên ' + @MAGV + N' tham gia là: ' + CAST(@SODT AS VARCHAR(2))
    END

EXEC SP_DEMDETAI '003'
DROP PROCEDURE SP_DEMDETAI

GO
CREATE FUNCTION F_DEMDETAI (@MAGV VARCHAR(9)) RETURNS INT
    AS BEGIN
        DECLARE @SODT INT
        SET @SODT = (SELECT COUNT(DISTINCT MADT)
                    FROM THAMGIADT
                    WHERE @MAGV = MAGV 
                    GROUP BY MAGV)
        RETURN @SODT
    END
-- DROP FUNCTION F_DEMDETAI

GO
CREATE FUNCTION F_DEMTHANNHAN (@MAGV VARCHAR(9)) RETURNS INT
    AS BEGIN
        DECLARE @SLTN INT 
        SET @SLTN = (SELECT COUNT(TEN)
                    FROM NGUOITHAN
                    WHERE @MAGV = MAGV 
                    GROUP BY MAGV)
        RETURN @SLTN
    END
-- DROP FUNCTION F_DEMTHANNHAN
/* l. In thông tin chi tiết của một giáo viên(sử dụng lệnh print): Thông tin cá nhân, 
Số lượng đề tài tham gia, Số lượng thân nhân của giáo viên đó */
GO
CREATE PROC SP_INCHITIET @MAGV VARCHAR(9)
    AS BEGIN 
        DECLARE @SLDT INT, @SLTN INT

        -- IN SLDT THAM GIA:
        SET @SLDT = (SELECT COUNT(DISTINCT MADT)
                    FROM THAMGIADT 
                    WHERE @MAGV = MAGV
                    GROUP BY MAGV)
        PRINT N'Số lượng đề tài giáo viên ' + @MAGV + N' tham gia là: ' + CAST(@SLDT AS VARCHAR(2))

        -- IN SLTN: 
        SET @SLTN = (SELECT COUNT(TEN)
                    FROM NGUOITHAN
                    WHERE @MAGV = MAGV 
                    GROUP BY MAGV)
        PRINT N'Số lượng thân nhân giáo viên ' + @MAGV + N' là: ' + CAST(@SLTN AS VARCHAR(2))

        -- IN THÔNG TIN CÁ NHÂN: 
        DECLARE @LUONG DECIMAL(18, 1), 
                @PHAI NCHAR(3),
                @NGSINH DATE, 
                @DIACHI NVARCHAR(50),
                @TEN NVARCHAR(30)

        SET @TEN =  (
                        SELECT HOTEN 
                        FROM GIAOVIEN 
                        WHERE @MAGV = MAGV
                    )
        PRINT N'Họ tên giáo viên ' + @MAGV + N' là: ' + @TEN
        
        SET @LUONG = (
                        SELECT LUONG 
                        FROM GIAOVIEN 
                        WHERE @MAGV = MAGV
                    )
        PRINT N'Mức lương giáo viên ' + @MAGV + N' là: ' + CAST(@LUONG AS VARCHAR(10))
        
        SET @NGSINH = (
                        SELECT NGSINH 
                        FROM GIAOVIEN 
                        WHERE @MAGV = MAGV
                      )
        PRINT N'Ngày sinh ' + @MAGV + N' là: ' + CAST(@NGSINH AS VARCHAR(20))
        
        SET @DIACHI = ( 
                        SELECT DIACHI 
                        FROM GIAOVIEN 
                        WHERE @MAGV = MAGV
                      )
        PRINT N'Địa chỉ giáo viên ' + @MAGV + N' là: ' + @DIACHI
    END 

EXEC SP_INCHITIET '001'
DROP PROCEDURE SP_INCHITIET

/* m. Kiểm tra xem một giáo viên có tồn tại hay không (dựa vào MAGV). */
GO
CREATE PROC SP_KTTONTAI @MAGV VARCHAR(9)
    AS BEGIN
        IF (EXISTS( SELECT *
                    FROM GIAOVIEN 
                    WHERE @MAGV = MAGV))
            BEGIN 
                PRINT N'Giáo viên ' + @MAGV + N' tồn tại trong cơ sở dữ liệu.'
            END  
        ELSE 
            BEGIN 
                PRINT N'Không tồn tại giáo viên ' + @MAGV + N' trong cơ sở dữ liệu.'
            END 
    END 

EXEC SP_KTTONTAI '012'
DROP PROC SP_KTTONTAI

/* n. Kiểm tra quy định của một giáo viên: Chỉ được thực hiện các đề tài mà bộ môn của giáo viên đó làm chủ nhiệm. 
- Thực hiện các đề tài -> Giáo viên này, tham gia vào đúng chủ đề giáo viên kia làm trưởng. 
- Bộ môn giáo viên đó làm chủ nhiệm ->  Tìm một giáo viên, thuộc cùng mã bộ môn, là trưởng đề tài.
*/ 

GO 
CREATE PROC SP_KTTQUYDINH @MAGV VARCHAR(9), @MADT VARCHAR(3)
    AS BEGIN 
        DECLARE @CHECK INT, 
                @CNDT VARCHAR(9)
        SET @CNDT = (
                        SELECT GVCNDT 
                        FROM DETAI 
                        WHERE @MADT = MADT 
                    )
        
        IF (SELECT MABM FROM GIAOVIEN WHERE MAGV = @MAGV) = (SELECT MABM FROM GIAOVIEN WHERE MAGV = @CNDT)
            BEGIN
                PRINT N'Giáo viên ' + @MAGV + ' có thể tham gia đề tài ' + @MADT + N' vì đủ điều kiện' 
            END 
        ELSE 
            BEGIN 
                PRINT N'Giáo viên ' + @MAGV + ' không thể tham gia đề tài ' + @MADT + N' vì chưa đủ điều kiện' 
            END 
    END 

EXEC SP_KTTQUYDINH '002', '001'
DROP PROC SP_KTTQUYDINH


/* 
o. Thực hiện thêm một phân công cho giáo viên thực hiện một công việc của
đề tài:
    o Kiểm tra thông tin đầu vào hợp lệ: giáo viên phải tồn tại, công việc
phải tồn tại, thời gian tham gia phải > 0
    o Kiểm tra quy định ở câu n.
*/ 
--------------------------------------------------------------------
GO 
CREATE FUNCTION F_KTRAHOPLE (@MAGV VARCHAR(9)) RETURNS INT 
    AS BEGIN
        IF (EXISTS( SELECT *
                    FROM GIAOVIEN 
                    WHERE @MAGV = MAGV))
            BEGIN 
                RETURN 1
            END  
        RETURN 0
    END 

--------------------------------------------------------------------
GO 
CREATE FUNCTION F_KTRACONGVIEC (@STT INT) RETURNS INT 
    AS BEGIN
        IF (EXISTS( SELECT *
                    FROM CONGVIEC 
                    WHERE @STT = SOTT))
            BEGIN 
                RETURN 1
            END  
        RETURN 0
    END 
--------------------------------------------------------------------
GO 
CREATE FUNCTION F_KTRATHOIGIAN (@SOTT INT, @MADT VARCHAR(3)) RETURNS INT 
    AS BEGIN 
        DECLARE @NGAYBD DATE = (SELECT NGAYBD FROM CONGVIEC WHERE @SOTT = SOTT AND MADT = @MADT), 
                @NGAYKT DATE = (SELECT NGAYKT FROM CONGVIEC WHERE @SOTT = SOTT AND MADT = @MADT)

        IF (DATEDIFF(DAY, @NGAYBD, @NGAYKT) > 0)
            BEGIN 
                RETURN 1
            END 
        RETURN 0
    END 
-- DROP FUNCTION F_KTRATHOIGIAN
-------------------------------------------------------------------------
GO 
CREATE FUNCTION F_KTTQUYDINH (@MAGV VARCHAR(9), @MADT VARCHAR(3)) RETURNS INT 
    AS BEGIN 
        DECLARE @CHECK INT, 
                @CNDT VARCHAR(9)
        SET @CNDT = (
                        SELECT GVCNDT 
                        FROM DETAI 
                        WHERE @MADT = MADT 
                    )
        
        IF (SELECT MABM FROM GIAOVIEN WHERE MAGV = @MAGV) = (SELECT MABM FROM GIAOVIEN WHERE MAGV = @CNDT)
            BEGIN
                RETURN 1 
            END 
        RETURN 0 
    END 

----------------------------------------------------------------------------
GO 
CREATE PROC SP_KTRAPHANCONG @MAGV VARCHAR(9), @SOTT INT, @MADT VARCHAR(3)
    AS BEGIN 
        DECLARE @CHECKTONTAIGV INT,
                @CHECKTONTAICV INT,
                @CHECKTHOIGIAN INT, 
                @CHECKCAUN INT

        SET @CHECKTONTAIGV = dbo.F_KTRAHOPLE(@MAGV)
        SET @CHECKTONTAICV = dbo.F_KTRACONGVIEC(@SOTT)
        SET @CHECKTHOIGIAN = dbo.F_KTRATHOIGIAN(@SOTT, @MADT)
        SET @CHECKCAUN = dbo.F_KTTQUYDINH(@MAGV, @MADT)

        IF (@CHECKTONTAICV + @CHECKTHOIGIAN + @CHECKCAUN + @CHECKTONTAIGV) = 4
            BEGIN
                PRINT N'Có thể phân công công việc: ' + CAST(@SOTT AS VARCHAR(1)) + N' cho giáo viên ' + @MAGV 
            END 
        ELSE 
            BEGIN 
                PRINT N'Không thể phân công công việc: ' + CAST(@SOTT AS VARCHAR(1)) + N' cho giáo viên ' + @MAGV
            END 
    END 
-- DROP PROC SP_KTRAPHANCONG
EXEC SP_KTRAPHANCONG '002', 1, '001'

/* p. Thực hiện xoá một giáo viên theo mã. Nếu giáo viên có thông tin liên quan
(Có thân nhân, có làm đề tài, ...) thì báo lỗi.*/
GO
CREATE PROC SP_KTRAXOA @MAGV VARCHAR(9) 
    AS BEGIN 
        DECLARE @CHECKTONTAI INT = dbo.F_KTRAHOPLE(@MAGV)
        IF @CHECKTONTAI = 0
            BEGIN
                RAISERROR(N'Giáo viên này không tồn tại', 16, 1) 
                RETURN
            END 
        
        IF (EXISTS( SELECT * FROM NGUOITHAN WHERE @MAGV = MAGV ))
            BEGIN
                RAISERROR(N'Giáo viên này liên quan đến thuộc tính khác', 16, 1) 
                RETURN 
            END 
        IF (EXISTS( SELECT * FROM THAMGIADT WHERE @MAGV = MAGV ))
            BEGIN
                RAISERROR(N'Giáo viên này liên quan đến thuộc tính khác', 16, 1) 
                RETURN
            END  
        IF (EXISTS( SELECT * FROM DETAI WHERE @MAGV = GVCNDT ))
            BEGIN
                RAISERROR(N'Giáo viên này liên quan đến thuộc tính khác', 16, 1) 
                RETURN
            END 
        IF (EXISTS( SELECT * FROM BOMON WHERE @MAGV = TRUONGBM ))
            BEGIN
                RAISERROR(N'Giáo viên này liên quan đến thuộc tính khác', 16, 1) 
                RETURN
            END 
        IF (EXISTS( SELECT * FROM KHOA WHERE @MAGV = TRUONGKHOA ))
            BEGIN
                RAISERROR(N'Giáo viên này liên quan đến thuộc tính khác', 16, 1) 
                RETURN
            END 
        IF (EXISTS( SELECT * FROM GV_DT WHERE @MAGV = MAGV ))
            BEGIN
                RAISERROR(N'Giáo viên này liên quan đến thuộc tính khác', 16, 1) 
                RETURN
            END 

        DELETE FROM GIAOVIEN WHERE MAGV = @MAGV 
        PRINT(N'Xóa xong') 
    END 

EXEC SP_KTRAXOA '110'

/*q. In ra danh sách giáo viên của một phòng ban nào đó cùng với số lượng đề
tài mà giáo viên tham gia, số thân nhân, số giáo viên mà giáo viên đó quản
lý nếu có, ... */

GO 
CREATE PROC SP_INPHONGBAN @MABM NCHAR(4)
    AS BEGIN
        SELECT *, dbo.F_DEMTHANNHAN(MAGV) AS N'Số thân nhân', dbo.F_DEMDETAI(MAGV) AS N'Số đề tài'
        FROM GIAOVIEN AS GV
        WHERE GV.MABM = @MABM 
    END 

EXEC SP_INPHONGBAN 'HTTT'
DROP PROC SP_INPHONGBAN

/* r. Kiểm tra quy định của 2 giáo viên a, b: Nếu a là trưởng bộ môn c của b thì
lương của a phải cao hơn lương của b. (a, b: mã giáo viên) */
GO
CREATE PROC SP_KTRATRUONGBM @MAGVA VARCHAR(9), @MAGVB VARCHAR(9)
    AS BEGIN 
        IF ((SELECT MABM FROM GIAOVIEN WHERE @MAGVA = MAGV) = (SELECT MABM FROM GIAOVIEN WHERE @MAGVB = MAGV)) 
            BEGIN 
                IF (EXISTS( SELECT * FROM BOMON WHERE @MAGVA = TRUONGBM))
                    BEGIN
                        IF (SELECT LUONG FROM GIAOVIEN WHERE @MAGVA = MAGV) > (SELECT LUONG FROM GIAOVIEN WHERE @MAGVB = MAGV)
                            BEGIN 
                                PRINT N'Giáo viên ' + @MAGVA + N' có lương lớn hơn ' + @MAGVB + N' và điều này đúng.'
                            END 
                        ELSE 
                            BEGIN 
                                PRINT N'Giáo viên ' + @MAGVA + N' có lương nhỏ hơn ' + @MAGVB + N' và điều này sai.'
                            END 
                    END 
                ELSE 
                    BEGIN 
                        PRINT N'Giáo viên ' + @MAGVA + N' không là trưởng bộ môn.'
                    END  
            END 
        ELSE 
            BEGIN 
                PRINT N'Giáo viên ' + @MAGVA + N' khác bộ môn ' + @MAGVB + N' và điều này sai.'
            END 
    END 
-- DROP PROC SP_KTRATRUONGBM
EXEC SP_KTRATRUONGBM '002', '003'

/*
s. Thêm một giáo viên: Kiểm tra các quy định: Không trùng tên, tuổi > 18, lương > 0
*/
GO
CREATE PROCEDURE SP_THEMGV @MAGV varchar(9), @HOTEN nvarchar(30), @LUONG int, @PHAI nchar(3), @NGSINH date, @DIACHI nvarchar(50), @GVQLCM varchar(3), @MABM  nchar(4)
    AS BEGIN 
        IF (EXISTS(SELECT HOTEN FROM GIAOVIEN WHERE @HOTEN = HOTEN))
            BEGIN
                RAISERROR(N'Tên bị trùng, thêm lại',16,1)
                RETURN
            END 
            IF (YEAR(GetDate()) - YEAR(@NGSINH) < 18)            
            BEGIN
                RAISERROR(N'Tuổi nhỏ hơn 18, thêm lại',16,1)
                RETURN
            END 
        IF (@LUONG <= 0)
            BEGIN
                RAISERROR(N'Lương sai, thêm lại',16,1)
                RETURN
            END 
        
        INSERT INTO GIAOVIEN(MAGV, HOTEN, LUONG, PHAI, NGSINH, DIACHI, GVQLCM, MABM)
        VALUES (@MAGV, @HOTEN, @LUONG, @PHAI, @NGSINH, @DIACHI, @GVQLCM, @MABM)
        Print N'Thêm thành công!'

    END 
-- DROP PROC SP_THEMGV
EXEC SP_THEMGV '014', N'Hoàng Phước Vũ', 3000, N'Nam', '01/01/2022', N'29/1 Huế', NULL, NULL

/* 
t. Mã giáo viên được xác định tự động theo quy tắc: Nếu đã có giáo viên 001,
002, 003 thì MAGV của giáo viên mới sẽ là 004. Nếu đã có giáo viên 001,
002, 005 thì MAGV của giáo viên mới là 003. */ 
GO
CREATE PROCEDURE SP_TUDONGTHEM @MAGV varchar(3) out
AS
	DECLARE @num int
	DECLARE @temp varchar(3)
	SET @num = 1
	
	WHILE (1=1)
	BEGIN
		IF (@num < 10)
			BEGIN
				SET @temp = '00' + CAST(@num as varchar(1))
			END
		ELSE IF (@num < 100)
			BEGIN
				SET @temp = '0' + CAST(@num as varchar(2))
			END
		ELSE
			BEGIN
				SET @temp = CAST(@num as varchar(3))
			END
		
		IF (NOT EXISTS(SELECT * FROM GIAOVIEN WHERE MAGV = @temp))
			BEGIN
				Set @MaGV = @temp
				break
			END
		
		SET @num = @num + 1
	END

-- Test câu t
DECLARE @MaGV varchar(3)
Exec SP_TUDONGTHEM @MaGV out
Print @MaGV
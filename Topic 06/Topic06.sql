-- TOPIC 6: TRUY VẤN LỒNG NÂNG CAO -- 
-- 20127258 - HOÀNG PHƯỚC NGUYÊN --

/*
A. LÝ THUYẾT 
I. Các phép toán trên tập hợp: 
1. Phép trừ:   
    - EXCEPT.
    - NOT EXISTS hoặc NOT IN 
2. Phép giao: 
    - INTERSECT 
    - EXISTS hoặc IN 
    - Sử dụng phép kết.
3. Phép hội: 
    - UNION: 
    - EXISTS hoặc IN: 
4. Phép chia: 
    - Bị chia: R
    - Chia: S

    4.1. Có 3 cách sử dụng phép chia
    - Sử dụng EXCEPT: 
        SELECT R1.A, R1.B, R1.C
        FROM R R1
        WHERE NOT EXISTS((SELECT S.D, S.E FROM S)
                        EXCEPT
                        (SELECT R2.D, R2.E FROM R R2
                        WHERE R1.A = R2.A AND R1.B = R2.B AND R1.C = R2.C)
    - Sử dụng NOT EXISTS: 
        SELECT R1.A, R1.B, R1.C
        FROM R R1
        WHERE NOT EXISTS( SELECT * 
                        FROM S
                        WHERE NOT EXISTS (SELECT* 
                                        FROM R R2
                                        WHERE R2.D = S.D AND R2.E = S.E AND R1.A = R2.A AND R1.B = R2.B AND R1.C = R2.C))))
    - Sử dụng gom nhóm: 
        SELECT R.A
        FROM R
        [WHERE R.B IN(SELECT S.B FROM [WHERE <ĐK>]]
        GROUP BY R.A
        HAVING COUNT(DISTINCT R.B)=(SELECT COUNT(S.B)
                                    FROM S 
                                    [WHERE <ĐK>])

B. THỰC HÀNH
- Nếu đề bài có chữ tất cả thì hãy nghĩ đến phép chia.
)*/

GO
USE QLDT 
GO

/* PHÂN TÍCH VÍ DỤ: 
VD1: Tìm tất cả giáo viên tham gia tất cả đề tài (COUNT):
    Bị chia: THAMGIADT (MAGV, MADT...) -> Bảng này chứa tập lớn hơn mà MAGV không bị mất
    Chia: DETAI (MADT...)
*/

/* Q58: Cho biết tên giáo viên nào mà tham gia đề tài đủ tất cả các chủ đề 
- Phân tích: 
    + Bảng: GIAOVIEN, CHUDE 
    + Bị chia: GIAOVIEN 
    + Chia: THAMGIADT 
    --> Chọn bị chia chứa tất cả thuộc tính là GIAOVIEN
    --> Chọn bảng chia không chứa thuộc tính của nó là GIAOVIEN mà chỉ chứa thuộc tính CHUDE
    --> Dùng 3 cách thì sẽ như thế này: 
    */


-- NOT EXISTS:
SELECT GV.HOTEN
FROM GIAOVIEN AS GV 
WHERE NOT EXISTS(   (SELECT * 
                    FROM CHUDE AS CD
                    WHERE NOT EXISTS (SELECT *
                                    FROM THAMGIADT AS TG, DETAI AS DT 
                                    WHERE GV.MAGV = TG.MAGV AND TG.MADT = DT.MADT AND DT.MACD = CD.MACD)))

-- COUNT 
SELECT GV.HOTEN 
FROM GIAOVIEN AS GV, THAMGIADT AS TG, DETAI AS DT
WHERE GV.MAGV = TG.MAGV AND TG.MADT = DT.MADT 
GROUP BY GV.MAGV, GV.HOTEN 
HAVING COUNT(DISTINCT DT.MACD) = 
        (   SELECT COUNT(*) 
            FROM CHUDE
        )

/* Q58: Cho biết tên đề tài nào mà được tất cả các giáo viên của bộ môn HTTT tham gia: 
- Phân tích: 
    + Bị chia: DETAI
    + Chia: THAMGIADETAI, GIAOVIEN
*/

-- COUNT: 
SELECT DT.TENDT 
FROM DETAI AS DT, THAMGIADT AS TG, GIAOVIEN AS GV 
WHERE GV.MAGV = TG.MAGV AND TG.MADT = DT.MADT AND GV.MABM = 'HTTT' 
GROUP BY DT.TENDT
HAVING COUNT(DISTINCT GV.MAGV) = (SELECT COUNT(*) 
                                FROM GIAOVIEN 
                                WHERE GIAOVIEN.MABM = 'HTTT')

-- EXCEPT:
SELECT DT.TENDT 
FROM DETAI AS DT 
WHERE NOT EXISTS(   SELECT GV.MAGV -- Chọn ra bảng chia 
                    FROM GIAOVIEN AS GV
                    WHERE GV.MABM = 'HTTT'
                    EXCEPT
                    SELECT TG.MAGV 
                    FROM THAMGIADT AS TG 
                    WHERE TG.MADT = DT.MADT
                )

/* Q60: Cho biết tên đề tài có tất cả giảng viên bộ môn "Hệ thống thông tin" tham gia.
- Phân tích:
    + Bị chia: (MADT, MAGV) GIÁO VIÊN BỘ MÔN HỆ THÔNG TIN THAM GIA ĐỀ TÀI 
    + Chia: MAGV CỦA GIAOVIEN BM HTTT*/

-- EXCEPT
SELECT DT.TENDT 
FROM DETAI AS DT 
WHERE NOT EXISTS(   SELECT GV.MAGV -- Chia, tìm MAGV của BM HTTT
                    FROM GIAOVIEN AS GV, BOMON AS BM
                    WHERE GV.MABM = BM.MABM AND BM.TENBM = N'Hệ thống thông tin'
                    EXCEPT 
                    SELECT TG.MAGV -- EXCEPT cùng thuộc tính, Giảng viên có tham gia đề tài  
                    FROM THAMGIADT AS TG
                    WHERE TG.MADT = DT.MADT
                )

/* Q61: Cho biết giáo viên nào đã tham gia tất cả đề tài có mã chủ đề là QLGD 
- Phân tích: 
    + Bị chia: Tất cả đề tài có giáo viên tham gia
    + Chia: Đếm tất cả các đề tài có mã chủ đề QLGD */
-- EXCEPT 
SELECT GV.HOTEN 
FROM GIAOVIEN AS GV 
WHERE NOT EXISTS(   SELECT DT.MADT 
                    FROM DETAI AS DT
                    WHERE DT.MACD = 'QLGD'
                    EXCEPT 
                    SELECT TG.MADT 
                    FROM THAMGIADT AS TG 
                    WHERE GV.MAGV = TG.MAGV
                )

/* Q62: Cho biết tên giáo viên nào tham gia tất cả các đề tài mà giáo viên trần trà hương tham gia: 
- Phân tích: 
    + Bị chia: Tất cả đề tài giáo viên tham gia đề tài.
    + Chia: Đếm đề tài có các giáo viên tth tham gia */
-- EXCEPT: 
SELECT GV.HOTEN 
FROM GIAOVIEN AS GV
WHERE NOT EXISTS(   SELECT TG.MADT 
                    FROM GIAOVIEN AS GV, THAMGIADT AS TG
                    WHERE GV.HOTEN = N'Trần Trà Hương' AND TG.MAGV = GV.MAGV
                    EXCEPT 
                    SELECT TG.MADT 
                    FROM THAMGIADT AS TG
                    WHERE GV.MAGV = TG.MAGV AND GV.HOTEN NOT LIKE N'Trần Trà Hương'
                )

/* Q63: Cho biết tên đề tài nào mà được tất cả các giáo viên bộ môn hóa hữu cơ tham gia: 
- Phân tích: 
    + Bị chia: Tất cả các giáo viên tham gia đề tài 
    + CHia: Đếm giáo viên bộ môn HHC */


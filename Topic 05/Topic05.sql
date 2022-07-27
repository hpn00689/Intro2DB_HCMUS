-- TOPIC 5: TRUY VẤN LỒNG -- 
-- 20127258 - HOÀNG PHƯỚC NGUYÊN -- 

/* A: LÝ THUYẾT
I. Khái niệm truy vấn lồng:
- Truy vấn lồng: Bên trong câu truy vấn chứa một câu truy vấn khác.
- 2 loại truy vấn lồng: Thứ cấp (con độc lập cha), tương quan (con phụ thuộc cha). 

II. Lồng phân cấp với các toán tử:
- IN: Kiểm tra giá trị có nằm trong tập hợp nào đó hay không, ngược lại với dẫn xuất của nó là NOT IN.
- ALL: Sử dụng với các toán tử so sánh >, <, >=... cho điều kiện đúng nếu giá trị thuộc tính đó >, <. >= với mọi phần tử trong tập hợp (!ALL = NOT IN).
- SOME, ANY: Khi muốn bất kỳ một phần tử trong tập hợp thỏa mãn. (Thay thế IN bằng cách sử dụng = ANY).

III. Lồng tương quan với các toán tử: 
- EXISTS: Chân trị của mệnh đề exists được cho là true nếu kết quả của câu truy vấn con trả về một bộ trở lên, ngược lại thì là false. Ngược lại với NOT EXITS. */

-- B: THỰC HÀNH
GO 
USE QLDT
GO 

/* Q35: Cho biết mức lương cao nhất của các giảng viên.
- Phân tích yêu cầu:
    + Cao nhất: sử dụng >= ALL thuộc tính tương tự. 
    + Từ bảng giáo viên lấy ra lương. */

SELECT LUONG 
FROM GIAOVIEN 
WHERE LUONG >= ALL( SELECT LUONG
                    FROM GIAOVIEN)

/* Q36: Cho biết những giáo viên có lương lớn nhất. 
- Phân tích yêu cầu: 
    + Lớn nhất: Sử dụng >= ALL thuộc tính tương tự.
    + Từ bảng giáo viên tìm lương lớn nhất, đồng thời xuất ra tên của người đó. 
    + Nếu đề bài chỉ yêu cầu những giáo viên mà không nói gì thêm thì dùng tất cả thuộc tính của người đó */

SELECT HOTEN, LUONG 
FROM GIAOVIEN 
WHERE LUONG >= ALL (SELECT LUONG 
                    FROM GIAOVIEN)

/* Q37: Cho biết lương cao nhất trong bộ môn HTTT.
- Phân tích yêu cầu: 
    + Cao nhất: >= ALL. 
    + HTTT: Tìm điều kiện giáo viên thuộc bộ môn HTTT.
    + Tìm lương lớn nhất, điều kiện thì đặt ở trong
    + Ngoài cách ở dưới có thể dùng cách group by để làm.
*/
SELECT LUONG AS N'Lương lớn nhất HTTT'
FROM GIAOVIEN 
WHERE LUONG >= ALL (SELECT LUONG 
                    FROM GIAOVIEN 
                    WHERE MABM = 'HTTT')
    AND MABM = 'HTTT'

/* Q38: Cho biết tên giáo viên lớn tuổi nhất của bộ môn HTTT.
- Phân tích yêu cầu: 
    + Lớn nhất: <= ALL 
    + Tính tuổi: Số năm nhỏ nhất thì số tuổi lớn.
    + Cách lấy số năm: YEAR() */
SELECT GV.HOTEN
FROM GIAOVIEN AS GV, BOMON AS BM
WHERE YEAR(NGSINH) <= ALL (SELECT YEAR(NGSINH)
                            FROM GIAOVIEN AS GV, BOMON AS BM
                            WHERE GV.MABM = BM.MABM AND BM.TENBM = N'Hệ thống thông tin')
        AND (GV.MABM = BM.MABM AND BM.TENBM = N'Hệ thống thông tin')

/* Q39: Cho biết tên giáo viên nhỏ tuổi nhất khoa CNTT 
- Phân tích yêu cầu: 
    + Nhỏ tuổi nhất: >= ALL 
    + Tính tuổi: Số năm lớn nhất thì số tuổi nhỏ nhất.
    + Lấy được khoa CNTT: Kết 3 bảng GV, BM, KHOA.
    + Làm tương tự như câu 38. */ 
SELECT HOTEN 
FROM GIAOVIEN AS GV, BOMON AS BM, KHOA AS K
WHERE YEAR(NGSINH) >= ALL (SELECT YEAR(GV.NGSINH)
                           FROM GIAOVIEN AS GV, BOMON AS BM, KHOA AS K 
                           WHERE GV.MABM = BM.MABM AND BM.MAKHOA = K.MAKHOA AND K.TENKHOA = N'Công nghệ thông tin')
        AND (GV.MABM = BM.MABM AND BM.MAKHOA = K.MAKHOA AND K.TENKHOA = N'Công nghệ thông tin')

/* Q40: Cho biết tên GV và tên khoa của giáo viên có lương cao nhất
- Phân tích: 
    + Tương tự như các câu trước, nhưng bây giờ ta cần gắn 3 bảng lại với nhau*/
SELECT GV.HOTEN, K.TENKHOA 
FROM GIAOVIEN AS GV, BOMON AS BM, KHOA AS K 
WHERE GV.LUONG >= ALL  (SELECT LUONG
                        FROM GIAOVIEN)
    AND GV.MABM = BM.MABM AND BM.MAKHOA = K.MAKHOA

/* Q41: Cho biết những GV có lương lớn nhất trong bộ môn của họ: 
- Trường hợp cần lưu ý kỹ.
- Phân tích: 
    + Với cách làm tương tự như trên >= ALL.
    + Rã: Lương lớn nhất trong bộ môn của họ -> Kết lại trong bộ môn của nó, sử dụng lồng tương quan sẽ phù hợp hơn
        + Chung mã bộ môn, khác mã giáo viên */

SELECT GV1.* 
FROM GIAOVIEN AS GV1
WHERE GV1.LUONG >= ALL  (SELECT GV2.LUONG 
                        FROM GIAOVIEN AS GV2
                        WHERE GV1.MABM = GV2.MABM AND GV1.MAGV <> GV2.MAGV)

/* Q42: Cho biết tên những đề tài mà giáo viên Nguyễn Hoài An chưa tham gia: 
- Phân tích: 
    + Lấy bảng: THAMGIADT, DETAI, GIAOVIEN 
    + Chưa tham gia: sử dụng NOT IN hoặc NOT EXISTS, dùng NOT IN cho dễ.
    + Ghi nhớ: Có thể tách truy vấn lồng ra thành các truy vấn lồng nhỏ hơn nữa để dễ tính. */

SELECT TENDT  
FROM DETAI 
WHERE MADT NOT IN(SELECT MADT 
                    FROM THAMGIADT
                    WHERE MAGV IN(SELECT MAGV
                                FROM GIAOVIEN 
                                WHERE GIAOVIEN.HOTEN = N'Nguyễn Hoài An'))

/* Q43: Cho biết tên những đề tài mà giáo viên Nguyễn Hoài An chưa tham gia, xuất ra tên đề tài, tên người chủ nhiệm đề tài.
- Phân tích: 
    + Lấy bảng: THAMGIADT, DETAI, GIAOVIEN kết.
    + Cách làm tương tự như bên trên. */

SELECT DT.TENDT, GV.HOTEN AS N'Giáo viên chủ nhiệm đề tài'
FROM DETAI AS DT, GIAOVIEN AS GV 
WHERE MADT NOT IN(SELECT MADT 
                    FROM THAMGIADT
                    WHERE MAGV IN(SELECT MAGV
                                FROM GIAOVIEN 
                                WHERE GIAOVIEN.HOTEN = N'Nguyễn Hoài An'))
    AND DT.GVCNDT = GV.MAGV 

/* Q44: Cho biết tên những giáo viên khoa Công nghệ thông tin mà chưa tham gia đề tài nào.
- Phân tích: 
    + Lấy bảng: GIAOVIEN, KHOA, BOMON để kết. 
    + Sử dụng nhiều truy vấn lồng nhau. */

SELECT HOTEN
FROM GIAOVIEN
WHERE MABM IN(SELECT MABM 
                FROM BOMON 
                WHERE MAKHOA IN (SELECT MAKHOA 
                                FROM KHOA
                                WHERE TENKHOA = N'Công nghệ thông tin'))
    AND MAGV NOT IN (SELECT MAGV 
                    FROM THAMGIADT)

/* Q45: Tìm những giáo viên không tham gia bất kỳ đề tài nào.
- Phân tích: 
    + Sử dụng toán tử NOT IN hoặc NOT EXISTS.
    + Bảng: GIAOVIEN, THAMGIADT */

SELECT *
FROM GIAOVIEN 
WHERE MAGV NOT IN (SELECT MAGV 
                    FROM THAMGIADT)

/* Q46: Cho biết những giáo viên có lương lớn hơn lương cuả giáo viên Nguyễn Hoài An.
- Phân tích: 
    + Sử dụng bảng: GIAOVIEN. 
    + Không sử dụng toán tử, vì đề bài yêu cầu so sánh một số*/
SELECT * 
FROM GIAOVIEN 
WHERE LUONG > (SELECT LUONG
                FROM GIAOVIEN 
                WHERE HOTEN = N'Nguyễn Hoài An')

/* Q47: Tìm những trưởng bộ môn tham gia tối thiểu 1 đề tài. 
- Phân tích: 
    + Sử dụng bảng: GIAOVIEN, BOMON, THAMGIADT */

SELECT * 
FROM GIAOVIEN 
WHERE MAGV IN( SELECT TRUONGBM
                FROM BOMON)
    AND MAGV IN (SELECT MAGV 
                FROM THAMGIADT)

/* Q48: Tìm giáo viên trùng tên và cùng giới tính với các giáo viên khác trong cùng 1 bộ môn
- Phân tích: 
    + Sử dụng bảng: GIAOVIEN 
    + Tương quan: 
        + Các phần tử trùng: Tên, giới tính, bộ môn,
        + Phần tử khác: mã giáo viên. 
    + Sử dụng toán tử tồn tại cho dễ vì không có điều kiện gì để so sánh từ trước đó. */

SELECT * 
FROM GIAOVIEN AS GV1
WHERE EXISTS (SELECT *
            FROM GIAOVIEN AS GV2 
            WHERE GV1.HOTEN LIKE GV2.HOTEN AND GV1.PHAI = GV2.PHAI AND GV1.MABM = GV2.MABM AND GV1.MAGV <> GV2.MAGV)

/* Q49: Tìm những giáo viên có lương lớn hơn lương của ít nhất một giáo viên bộ môn "công nghệ phần mềm". 
- Phân tích: 
    + Sử dụng bảng: GIAOVIEN, BOMON 
    + Ít nhất một: Dùng ANY */ 

SELECT * 
FROM GIAOVIEN 
WHERE LUONG > ANY(SELECT LUONG 
                FROM GIAOVIEN 
                WHERE MABM IN (SELECT MABM
                                FROM BOMON 
                                WHERE TENBM = N'Công nghệ phần mềm'))

/* Q50: Tìm những giáo viên có lương lớn hơn lương của tất cả giáo viên thuộc bộ môn "Hệ thống thông tin".
- Phân tích: 
    + Sử dụng bảng: GIAOVIEN, BOMON
    + Lớn hơn tất cả: > ALL */

SELECT * 
FROM GIAOVIEN 
WHERE LUONG > ALL(SELECT LUONG 
                FROM GIAOVIEN 
                WHERE MABM IN (SELECT MABM 
                                FROM BOMON 
                                WHERE TENBM = N'Hệ thống thông tin'))

/* Q51: Cho biết tên khoa có đông giáo viên nhất: 
- Phân tích: 
    + Sử dụng bảng: KHOA, GIAOVIEN, BOMON
    + Đông giáo viên: Dùng count rồi having. 
    + Count từng khoa rồi sử dụng kết quả đó để đếm. */

SELECT K.TENKHOA 
FROM KHOA AS K, GIAOVIEN AS GV, BOMON AS BM 
WHERE GV.MABM = BM.MABM AND BM.MAKHOA = K.MAKHOA 
GROUP BY K.MAKHOA, K.TENKHOA
HAVING COUNT(*) >= ALL (SELECT COUNT(*)
                        FROM KHOA AS K, GIAOVIEN AS GV, BOMON AS BM 
                        WHERE GV.MABM = BM.MABM AND BM.MAKHOA = K.MAKHOA
                        GROUP BY K.MAKHOA, K.TENKHOA) 

/* Q52: Cho biết họ tên giáo viên chủ nhiệm nhiều đề tài nhất: 
- Phân tích: 
    + >= ALL
    + Bảng: GIAOVIEN, DETAI 
    + GROUP BY: GVCNDT
    + COUNT: * 
    + Key làm những bài kiểu như này: Tìm được thứ mình muốn group cái gì là ok.
    + Bóc: Nhiều đề tài nhất thì having trên đề tài */

SELECT HOTEN 
FROM GIAOVIEN 
WHERE MAGV IN (SELECT GVCNDT
                FROM DETAI 
                GROUP BY GVCNDT 
                HAVING COUNT(*) >= ALL (SELECT COUNT(*)
                                        FROM DETAI 
                                        GROUP BY GVCNDT ))

/* Q53: Cho biết mã bộ môn có nhiều giáo viên nhất: 
- Phân tích: 
    + >= ALL 
    + GROUP BY: MABM 
    + COUNT: * 
    + Nếu làm trên một bảng thì chỉ cần group nó lại thôi */

SELECT MABM
FROM GIAOVIEN 
GROUP BY MABM 
HAVING COUNT(*) >= ALL (SELECT COUNT(*)
                        FROM GIAOVIEN 
                        GROUP BY MABM)

/* Q54: Cho biết tên giáo viên và tên bộ môn của giáo viên tham gia nhiều đề tài nhất
- Phân tích: 
    + Bảng: GIAOVIEN, BOMON, THAMGIADT
    + GROUP BY: GIAOVIEN
    + Vì một giáo viên có thể làm cùng 1 đề tài với nhiều công việc khác nhau nên dùng count(distinct). */

SELECT GV.HOTEN, BM.TENBM 
FROM GIAOVIEN AS GV, BOMON AS BM 
WHERE GV.MABM = BM.MABM AND GV.MAGV IN (SELECT MAGV
                                        FROM THAMGIADT
                                        GROUP BY MAGV 
                                        HAVING COUNT(DISTINCT MADT) >= ALL (SELECT COUNT(DISTINCT MADT)
                                                                            FROM THAMGIADT
                                                                            GROUP BY MAGV))

/* Q55: Cho biết tên giáo viên tham gia nhiều đề tài nhất của bộ môn HTTT 
- Phân tích: 
    + Bảng: GIAOVIEN, THAMGIADT 
    + GROUP BY: GIAOVIEN 
    + COUNT: DISTINCT 
    + >= ALL */ 

SELECT HOTEN 
FROM GIAOVIEN 
WHERE MABM = N'HTTT' AND MAGV IN(SELECT MAGV
                                FROM THAMGIADT 
                                GROUP BY MAGV
                                HAVING COUNT(DISTINCT MADT) >= ALL (SELECT COUNT(DISTINCT MADT)
                                                                    FROM THAMGIADT
                                                                    GROUP BY MAGV))

/* Q56: Cho biết tên giáo viên và tên bộ môn của giáo viên có nhiều người thân nhất
- Phân tích: 
    + BOMON, GIAOVIEN, NGUOITHAN
    + COUNT: *
    + GROUP BY: MAGV 
    + >= ALL */

SELECT GV.HOTEN, BM.TENBM
FROM BOMON AS BM, GIAOVIEN AS GV
WHERE BM.MABM = GV.MABM AND GV.MAGV IN (SELECT MAGV 
                                        FROM NGUOITHAN 
                                        GROUP BY MAGV 
                                        HAVING COUNT(*) >= ALL(SELECT COUNT(*) 
                                                            FROM NGUOITHAN 
                                                            GROUP BY MAGV ))

/* Q57: Cho biết tên trưởng bộ môn mà chủ nhiệm nhiều đề tài nhất: 
- Phân tích: 
    + Bảng: BOMON, GIAOVIEN, DETAI
    + >= ALL 
    + GROUP BY: GVCNDT
    + COUNT * */

SELECT HOTEN 
FROM GIAOVIEN 
WHERE MAGV IN (SELECT TRUONGBM 
                FROM BOMON)
    AND MAGV IN (SELECT GVCNDT 
                FROM DETAI 
                GROUP BY GVCNDT 
                HAVING COUNT(*) >= ALL (SELECT COUNT(*)
                                        FROM DETAI
                                        GROUP BY GVCNDT))

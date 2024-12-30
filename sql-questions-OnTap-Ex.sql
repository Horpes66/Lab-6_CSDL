-- Câu hỏi SQL từ cơ bản đến nâng cao, bao gồm trigger

-- Cơ bản:
1. Liệt kê tất cả chuyên gia trong cơ sở dữ liệu.
SELECT * 
FROM ChuyenGia;

2. Hiển thị tên và email của các chuyên gia nữ.
SELECT TenChuyenGia, Email 
FROM ChuyenGia 
WHERE GioiTinh = 'Nữ';

3. Liệt kê các công ty có trên 100 nhân viên.
SELECT TenCongTy 
FROM CongTy 
WHERE SoLuongNhanVien > 100;

4. Hiển thị tên và ngày bắt đầu của các dự án trong năm 2023.
SELECT TenDuAn, NgayBatDau 
FROM DuAn 
WHERE YEAR(NgayBatDau) = 2023;

-- Trung cấp:
6. Liệt kê tên chuyên gia và số lượng dự án họ tham gia.
SELECT cg.TenChuyenGia, COUNT(cgd.MaDuAn) AS SoLuongDuAn
FROM ChuyenGia cg
LEFT JOIN ChuyenGia_DuAn cgd ON cg.MaChuyenGia = cgd.MaChuyenGia
GROUP BY cg.TenChuyenGia;

7. Tìm các dự án có sự tham gia của chuyên gia có kỹ năng 'Python' cấp độ 4 trở lên.
SELECT DISTINCT da.TenDuAn
FROM DuAn da
JOIN ChuyenGia_DuAn cgd ON da.MaDuAn = cgd.MaDuAn
JOIN ChuyenGia_KyNang cgk ON cgd.MaChuyenGia = cgk.MaChuyenGia
JOIN KyNang kn ON cgk.MaKyNang = kn.MaKyNang
WHERE kn.TenKyNang = 'Python' AND cgk.CapDo >= 4;

8. Hiển thị tên công ty và số lượng dự án đang thực hiện.
SELECT ct.TenCongTy, COUNT(da.MaDuAn) AS SoLuongDuAn
FROM CongTy ct
JOIN DuAn da ON ct.MaCongTy = da.MaCongTy
WHERE da.TrangThai = 'DangThucHien'
GROUP BY ct.TenCongTy;

9. Tìm chuyên gia có số năm kinh nghiệm cao nhất trong mỗi chuyên ngành.
SELECT ChuyenNganh, TenChuyenGia, MAX(SoNamKinhNghiem) AS SoNamKinhNghiem
FROM ChuyenGia
GROUP BY ChuyenNganh, TenChuyenGia;

10. Liệt kê các cặp chuyên gia đã từng làm việc cùng nhau trong ít nhất một dự án.
SELECT DISTINCT 
    c1.TenChuyenGia AS ChuyenGia1, 
    c2.TenChuyenGia AS ChuyenGia2
FROM ChuyenGia_DuAn cd1
JOIN ChuyenGia_DuAn cd2 ON cd1.MaDuAn = cd2.MaDuAn AND cd1.MaChuyenGia < cd2.MaChuyenGia
JOIN ChuyenGia c1 ON cd1.MaChuyenGia = c1.MaChuyenGia
JOIN ChuyenGia c2 ON cd2.MaChuyenGia = c2.MaChuyenGia;

-- Nâng cao:
11. Tính tổng thời gian (theo ngày) mà mỗi chuyên gia đã tham gia vào các dự án.
SELECT cg.TenChuyenGia, SUM(DATEDIFF(DAY, da.NgayBatDau, da.NgayKetThuc)) AS TongThoiGian
FROM ChuyenGia cg
JOIN ChuyenGia_DuAn cgd ON cg.MaChuyenGia = cgd.MaChuyenGia
JOIN DuAn da ON cgd.MaDuAn = da.MaDuAn
GROUP BY cg.TenChuyenGia;

12. Tìm các công ty có tỷ lệ dự án hoàn thành cao nhất (trên 90%).
SELECT TenCongTy, CAST(SUM(CASE WHEN TrangThai = 'HoanThanh' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) * 100 AS TiLeHoanThanh
FROM CongTy ct
JOIN DuAn da ON ct.MaCongTy = da.MaCongTy
GROUP BY TenCongTy
HAVING CAST(SUM(CASE WHEN TrangThai = 'HoanThanh' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) * 100 > 90;

13. Liệt kê top 3 kỹ năng được yêu cầu nhiều nhất trong các dự án.
SELECT TOP 3 kn.TenKyNang, COUNT(*) AS SoLanYeuCau
FROM DuAn da
JOIN ChuyenGia_DuAn cgd ON da.MaDuAn = cgd.MaDuAn
JOIN ChuyenGia_KyNang cgk ON cgd.MaChuyenGia = cgk.MaChuyenGia
JOIN KyNang kn ON cgk.MaKyNang = kn.MaKyNang
GROUP BY kn.TenKyNang
ORDER BY SoLanYeuCau DESC;

14. Tính lương trung bình của chuyên gia theo từng cấp độ kinh nghiệm (Junior: 0-2 năm, Middle: 3-5 năm, Senior: >5 năm).
SELECT 
    CASE 
        WHEN SoNamKinhNghiem BETWEEN 0 AND 2 THEN 'Junior'
        WHEN SoNamKinhNghiem BETWEEN 3 AND 5 THEN 'Middle'
        ELSE 'Senior'
    END AS CapDoKinhNghiem,
    AVG(Luong) AS LuongTrungBinh
FROM ChuyenGia
GROUP BY 
    CASE 
        WHEN SoNamKinhNghiem BETWEEN 0 AND 2 THEN 'Junior'
        WHEN SoNamKinhNghiem BETWEEN 3 AND 5 THEN 'Middle'
        ELSE 'Senior'
    END;

15. Tìm các dự án có sự tham gia của chuyên gia từ tất cả các chuyên ngành.

-- Trigger:
16. Tạo một trigger để tự động cập nhật số lượng dự án của công ty khi thêm hoặc xóa dự án.
CREATE TRIGGER trg_UpdateSoLuongDuAn
ON DuAn
AFTER INSERT, DELETE
AS
BEGIN
    UPDATE CongTy
    SET SoLuongDuAn = (
        SELECT COUNT(*) 
        FROM DuAn 
        WHERE DuAn.MaCongTy = CongTy.MaCongTy
    );
END;

17. Tạo một trigger để ghi log mỗi khi có sự thay đổi trong bảng ChuyenGia.
CREATE TABLE ChuyenGia_Log (
    LogID INT IDENTITY PRIMARY KEY,
    MaChuyenGia INT,
    HanhDong NVARCHAR(50),
    NgayThayDoi DATETIME
);

CREATE TRIGGER trg_LogChuyenGia
ON ChuyenGia
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    INSERT INTO ChuyenGia_Log (MaChuyenGia, HanhDong, NgayThayDoi)
    SELECT 
        ISNULL(i.MaChuyenGia, d.MaChuyenGia),
        CASE 
            WHEN EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted) THEN 'UPDATE'
            WHEN EXISTS (SELECT * FROM inserted) THEN 'INSERT'
            ELSE 'DELETE'
        END,
        GETDATE()
    FROM inserted i
    FULL OUTER JOIN deleted d ON i.MaChuyenGia = d.MaChuyenGia;
END;

18. Tạo một trigger để đảm bảo rằng một chuyên gia không thể tham gia vào quá 5 dự án cùng một lúc.
CREATE TRIGGER trg_LimitChuyenGiaDuAn
ON ChuyenGia_DuAn
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT MaChuyenGia
        FROM ChuyenGia_DuAn
        GROUP BY MaChuyenGia
        HAVING COUNT(*) > 5
    )
    BEGIN
        RAISERROR ('Một chuyên gia không thể tham gia quá 5 dự án!', 16, 1);
        ROLLBACK TRANSACTION;
    END;
END;

19. Tạo một trigger để tự động cập nhật trạng thái của dự án thành 'Hoàn thành' khi tất cả chuyên gia đã kết thúc công việc.
CREATE TRIGGER trg_UpdateProjectStatus
ON ChuyenGia_DuAn
AFTER DELETE
AS
BEGIN
    UPDATE DuAn
    SET TrangThai = 'HoanThanh'
    WHERE NOT EXISTS (
        SELECT 1 
        FROM ChuyenGia_DuAn 
        WHERE DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn
    );
END;

20. Tạo một trigger để tự động tính toán và cập nhật điểm đánh giá trung bình của công ty dựa trên điểm đánh giá của các dự án.
CREATE TRIGGER trg_UpdateCongTyRating
ON DuAn
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE CongTy
    SET DiemDanhGiaTrungBinh = (
        SELECT AVG(DiemDanhGia) 
        FROM DuAn 
        WHERE DuAn.MaCongTy = CongTy.MaCongTy
    );
END;

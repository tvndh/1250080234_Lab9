-- Phi?u 1
-- 1. B?ng HANG
CREATE TABLE Hang (
    Mahang VARCHAR2(10) PRIMARY KEY,
    Tenhang VARCHAR2(100),
    Soluong NUMBER,
    Giaban NUMBER
);
-- 2. B?ng HOADON
CREATE TABLE Hoadon (
    Mahd VARCHAR2(10) PRIMARY KEY,
    Mahang VARCHAR2(10),
    Soluongban NUMBER,
    Ngayban DATE,
    CONSTRAINT fk_hoadon_hang FOREIGN KEY (Mahang) REFERENCES Hang(Mahang)
);

INSERT INTO Hang (Mahang, Tenhang, Soluong, Giaban) 
VALUES ('H01', 'Bàn phím cõ Logitech', 100, 1500000);

INSERT INTO Hang (Mahang, Tenhang, Soluong, Giaban) 
VALUES ('H02', 'Chu?t không dây Razer', 50, 800000);

INSERT INTO Hang (Mahang, Tenhang, Soluong, Giaban) 
VALUES ('H03', 'Màn h?nh Dell 24 inch', 20, 4500000);

COMMIT;
-- Bài 1 – Trigger INSERT trên b?ng HOADON
CREATE OR REPLACE TRIGGER trg_insert_hoadon 
BEFORE INSERT ON Hoadon 
FOR EACH ROW 
DECLARE 
    v_dem NUMBER := 0; 
    v_soluong_ton NUMBER := 0;
BEGIN 
    -- 1.Mahang có t?n t?i trong b?ng HANG không? N?u không ? ðýa ra thông báo l?i và h?y giao d?ch.
    SELECT COUNT(*) INTO v_dem FROM Hang WHERE Mahang = :NEW.Mahang; 
    IF v_dem = 0 THEN 
        RAISE_APPLICATION_ERROR(-20001, 'Loi: Ma hang khong ton tai'); 
    END IF; 

    -- L?y s? lý?ng t?n kho hi?n t?i
    SELECT Soluong INTO v_soluong_ton FROM Hang WHERE Mahang = :NEW.Mahang;

    -- 2.Soluongban <= Soluong t?n kho? N?u không ? thông báo l?i và h?y giao d?ch.
    IF :NEW.Soluongban > v_soluong_ton THEN
        RAISE_APPLICATION_ERROR(-20002, 'Loi: So luong ban vuot qua so luong ton kho');
    END IF;

    -- 3.N?u th?a m?n ? UPDATE: Soluong = Soluong - Soluongban.
    UPDATE Hang 
    SET Soluong = Soluong - :NEW.Soluongban 
    WHERE Mahang = :NEW.Mahang; 
END trg_insert_hoadon; 
/
-- Test:
-- Test 1:
INSERT INTO Hoadon(Mahd, Mahang, Soluongban, Ngayban) VALUES ('HD01', 'H99', 10, SYSDATE);

-- Test 2: 
INSERT INTO Hoadon(Mahd, Mahang, Soluongban, Ngayban) VALUES ('HD02', 'H01', 200, SYSDATE);

-- Test 3:
INSERT INTO Hoadon(Mahd, Mahang, Soluongban, Ngayban) VALUES ('HD03', 'H01', 10, SYSDATE);
-- Bài 2 – Trigger DELETE trên b?ng HOADON
CREATE OR REPLACE TRIGGER trg_delete_hoadon 
AFTER DELETE ON Hoadon 
FOR EACH ROW 
BEGIN 
    -- C?ng l?i s? lý?ng khi hóa ðõn b? xóa 
    UPDATE Hang 
    SET Soluong = Soluong + :OLD.Soluongban 
    WHERE Mahang = :OLD.Mahang; 
END trg_delete_hoadon; 
/
-- Test:
DELETE FROM Hoadon WHERE Mahd = 'HD03';
-- Bài 3 – Trigger UPDATE trên b?ng HOADON
CREATE OR REPLACE TRIGGER trg_update_hoadon 
BEFORE UPDATE ON Hoadon 
FOR EACH ROW 
BEGIN 
-- Ði?u ch?nh t?n kho theo chênh l?ch (SoluongbanMoi - SoluongbanCu)
    UPDATE Hang 
    SET Soluong = Soluong - (:NEW.Soluongban - :OLD.Soluongban) 
    WHERE Mahang = :NEW.Mahang; 
END trg_update_hoadon; 
/
-- Test:
INSERT INTO Hoadon(Mahd, Mahang, Soluongban, Ngayban) VALUES ('HD04', 'H01', 10, SYSDATE);

UPDATE Hoadon SET Soluongban = 15 WHERE Mahd = 'HD04';

UPDATE Hoadon SET Soluongban = 5 WHERE Mahd = 'HD04';
-- Phi?u 2
--1. B?ng Mathang
CREATE TABLE Mathang (
Mahang VARCHAR2(5) CONSTRAINT pk_mathang PRIMARY KEY,
Tenhang VARCHAR2(50) NOT NULL,
Soluong NUMBER(10)
);
--2. B?ng Nhatkybanhang
CREATE TABLE Nhatkybanhang (
Stt NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
Ngay DATE,
Nguoimua VARCHAR2(50),
Mahang VARCHAR2(5) REFERENCES Mathang(Mahang),
Soluong NUMBER(10),
Giaban NUMBER(15,2)
);

INSERT INTO Mathang VALUES ('1','Hang A', 100);
INSERT INTO Mathang VALUES ('2','Hang B', 200);
INSERT INTO Mathang VALUES ('3','Hang C', 150);
COMMIT;

-- a. Trigger trg_nhatkybanhang_insert
CREATE OR REPLACE TRIGGER trg_nhatkybanhang_insert
AFTER INSERT ON Nhatkybanhang
FOR EACH ROW
BEGIN
    UPDATE Mathang
    SET Soluong = Soluong - :NEW.Soluong
    WHERE Mahang = :NEW.Mahang;
END;
/
-- Test
INSERT INTO Nhatkybanhang (Ngay, Nguoimua, Mahang, Soluong, Giaban) 
VALUES (SYSDATE, 'Nguyen Van A', '1', 10, 50000);
-- b. Trigger trg_nhatkybanhang_update_soluong
CREATE OR REPLACE TRIGGER trg_nkh_update_soluong
AFTER UPDATE OF Soluong ON Nhatkybanhang
FOR EACH ROW
BEGIN
    UPDATE Mathang
    SET Soluong = Soluong - (:NEW.Soluong - :OLD.Soluong)
    WHERE Mahang = :NEW.Mahang;
END;
/
-- Test
UPDATE Nhatkybanhang SET Soluong = 15 WHERE Stt = 1;
-- c. Trigger INSERT có ki?m tra s? lý?ng h?p l?
CREATE OR REPLACE TRIGGER trg_nkh_insert_kiemtra
BEFORE INSERT ON Nhatkybanhang
FOR EACH ROW
DECLARE
    v_tonkho NUMBER;
BEGIN
    -- L?y s? lý?ng t?n kho hi?n t?i
    SELECT Soluong INTO v_tonkho FROM Mathang WHERE Mahang = :NEW.Mahang;
    
    -- Ki?m tra ði?u ki?n
    IF :NEW.Soluong > v_tonkho THEN
        RAISE_APPLICATION_ERROR(-20001, 'Loi: So luong ban vuot qua so luong ton kho!');
    ELSE
        UPDATE Mathang
        SET Soluong = Soluong - :NEW.Soluong
        WHERE Mahang = :NEW.Mahang;
    END IF;
END;
/

-- Test:
INSERT INTO Nhatkybanhang (Ngay, Nguoimua, Mahang, Soluong, Giaban) 
VALUES (SYSDATE, 'Tran Thi B', '2', 500, 60000);
-- d. Trigger UPDATE ki?m soát s? d?ng (Compound Trigger)
CREATE OR REPLACE TRIGGER trg_nkh_update_compound
FOR UPDATE ON Nhatkybanhang
COMPOUND TRIGGER

    v_count NUMBER := 0;

    BEFORE STATEMENT IS
    BEGIN
        v_count := 0; 
    END BEFORE STATEMENT;

    AFTER EACH ROW IS
    BEGIN
        v_count := v_count + 1;
        IF v_count > 1 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Loi: Chi duoc cap nhat 1 dong moi lan!');
        END IF;
        
        -- C?p nh?t l?i kho
        UPDATE Mathang
        SET Soluong = Soluong - (:NEW.Soluong - :OLD.Soluong)
        WHERE Mahang = :NEW.Mahang;
    END AFTER EACH ROW;
END trg_nkh_update_compound;
/
-- Test:
UPDATE Nhatkybanhang SET Soluong = 20;
-- e. Trigger DELETE ki?m soát s? d?ng
CREATE OR REPLACE TRIGGER trg_nkh_delete_compound
FOR DELETE ON Nhatkybanhang
COMPOUND TRIGGER
    v_count NUMBER := 0;

    BEFORE STATEMENT IS
    BEGIN
        v_count := 0;
    END BEFORE STATEMENT;

    AFTER EACH ROW IS
    BEGIN
        v_count := v_count + 1;
        IF v_count > 1 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Loi: Chi duoc xoa 1 dong moi lan!');
        END IF;
        
        -- Hoàn tr? s? lý?ng vào kho
        UPDATE Mathang
        SET Soluong = Soluong + :OLD.Soluong
        WHERE Mahang = :OLD.Mahang;
    END AFTER EACH ROW;
END trg_nkh_delete_compound;
/
-- Test:
DELETE FROM Nhatkybanhang;
-- f. Trigger UPDATE nâng cao – Ki?m tra nhi?u ði?u ki?n
CREATE OR REPLACE TRIGGER trg_nkh_update_nangcao
FOR UPDATE ON Nhatkybanhang
COMPOUND TRIGGER
    v_count NUMBER := 0;
    v_tonkho NUMBER;

    BEFORE STATEMENT IS
    BEGIN
        v_count := 0;
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN
        v_count := v_count + 1;
        IF v_count > 1 THEN
            RAISE_APPLICATION_ERROR(-20004, 'Loi: Khong duoc update nhieu hon 1 ban ghi!');
        END IF;
        
        -- L?y t?n kho hi?n t?i
        SELECT Soluong + :OLD.Soluong INTO v_tonkho FROM Mathang WHERE Mahang = :NEW.Mahang;

        IF :NEW.Soluong < v_tonkho THEN
            RAISE_APPLICATION_ERROR(-20005, 'Loi: Sai cap nhat (So luong cap nhat < ton kho)!');
        ELSIF :NEW.Soluong = v_tonkho THEN
            RAISE_APPLICATION_ERROR(-20006, 'Thong bao: Khong can cap nhat (So luong = ton kho)');
        ELSE
            -- H?p l? -> Ti?n hành tr? kho
            UPDATE Mathang
            SET Soluong = Soluong - (:NEW.Soluong - :OLD.Soluong)
            WHERE Mahang = :NEW.Mahang;
        END IF;
    END BEFORE EACH ROW;
END trg_nkh_update_nangcao;
/
-- g. Th? t?c xóa MATHANG (có tác ð?ng 2 b?ng)
CREATE OR REPLACE PROCEDURE proc_xoa_mathang (p_mahang IN VARCHAR2) 
IS
    v_ton_tai NUMBER;
BEGIN
    -- Ki?m tra m? hàng có t?n t?i không
    SELECT COUNT(*) INTO v_ton_tai FROM Mathang WHERE Mahang = p_mahang;
    
    IF v_ton_tai = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Thong bao: Ma hang ' || p_mahang || ' khong ton tai!');
    ELSE
        -- 1. Xóa d? li?u liên quan ? b?ng con trý?c
        DELETE FROM Nhatkybanhang WHERE Mahang = p_mahang;
        -- 2. Xóa m?t hàng ? b?ng cha
        DELETE FROM Mathang WHERE Mahang = p_mahang;
        
        DBMS_OUTPUT.PUT_LINE('Da xoa thanh cong ma hang: ' || p_mahang);
        COMMIT;
    END IF;
END proc_xoa_mathang;
/

-- Test:
SET SERVEROUTPUT ON;
 EXECUTE proc_xoa_mathang('3');
-- h. Hàm tính t?ng ti?n theo tên hàng
CREATE OR REPLACE FUNCTION fn_TongTien(p_tenhang IN VARCHAR2) 
RETURN NUMBER 
IS
    v_tong NUMBER := 0;
BEGIN
    SELECT SUM(nk.Soluong * nk.Giaban) INTO v_tong
    FROM Nhatkybanhang nk
    JOIN Mathang mh ON nk.Mahang = mh.Mahang
    WHERE mh.Tenhang = p_tenhang;
    
    -- N?u chýa bán ðý?c món nào, tr? v? 0 thay v? NULL
    RETURN NVL(v_tong, 0);
END fn_TongTien;
/

-- Test:
SELECT fn_TongTien('Hang A') AS Tong_Tien_Ban FROM DUAL;
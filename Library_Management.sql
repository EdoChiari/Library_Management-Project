SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM return_status;
SELECT * FROM members

-- Project Task

--Task 1. Create a New Book Record "('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

--Task 2: Update an Existing Member's Address
UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';

--Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
DELETE FROM issued_status
WHERE issued_id = 'IS121';

--Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT *
FROM issued_status
WHERE issued_emp_id = 'E101';

--Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.
SELECT 
	issued_emp_id,
	COUNT(*) 
FROM issued_status
GROUP BY 1
HAVING COUNT(*) > 1;


--CTSA
--Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
CREATE TABLE book_issued_cnt AS
SELECT 
	b.isbn,
	b.book_title,
	COUNT(ist.issued_id) AS issue_count
FROM issued_status AS ist
JOIN books as b
ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;

--Data Analysis & Findings
--Task 7. Retrieve All Books in a Specific Category:
SELECT *
FROM books
WHERE category = 'Classic';

--Task 8: Find Total Rental Income by Category:
SELECT 
    b.category,
    SUM(b.rental_price),
    COUNT(*)
FROM issued_status as ist
JOIN books as b
ON b.isbn = ist.issued_book_isbn
GROUP BY 1;

-- Task 9: List Members Who Registered in the Last 180 Days:
SELECT * 
FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';

-- Task 10: List Employees with Their Branch Manager's Name and their branch details:
SELECT
	e1.emp_id,
	e1.emp_name,
	e1.position,
	e1.salary,
	b.*,
	e2.emp_name AS manager
FROM employees AS e1
JOIN
branch AS b
ON e1.branch_id = b.branch_id
JOIN
employees AS e2
ON e2.emp_id = b.manager_id
	
--Task 11: Create a Table of Books with Rental Price Above a Certain Threshold:
CREATE TABLE expensive_books AS 
SELECT * FROM books
WHERE rental_price > 7.00;

--Task 12: Retrieve the List of Books Not Yet Returned
SELECT 
	issued_book_name,
	issued_date
FROM issued_status AS ist
LEFT JOIN
return_status AS rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;

--Advanced SQL Operations
--Task 13: Identify Members with Overdue Books
SELECT 
    ist.issued_member_id,
    m.member_name,
    bk.book_title,
    ist.issued_date,
    -- rs.return_date,
    CURRENT_DATE - ist.issued_date as over_dues_days
FROM issued_status as ist
JOIN 
members as m
    ON m.member_id = ist.issued_member_id
JOIN 
books as bk
ON bk.isbn = ist.issued_book_isbn
LEFT JOIN 
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE 
    rs.return_date IS NULL
    AND
    (CURRENT_DATE - ist.issued_date) > 30
ORDER BY 1

--Task 14: Branch Performance Report
CREATE TABLE branch_reports
AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) as number_book_issued,
    COUNT(rs.return_id) as number_of_book_return,
    SUM(bk.rental_price) as total_revenue
FROM issued_status as ist
JOIN 
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
JOIN 
books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;

SELECT * FROM branch_reports;

--Task 15: CTAS: Create a Table of Active Members

CREATE TABLE active_members
AS
SELECT * 
FROM members
WHERE member_id IN (
	SELECT DISTINCT issued_member_id
	FROM issued_status
	WHERE issued_date >= CURRENT_DATE - INTERVAL '12' month
	)
;

SELECT * FROM active_members

--Task 16: Find Employees with the Most Book Issues Processed
SELECT 
	e.emp_name,
	b.*,
	COUNT(ist.issued_id) AS N_book_issued
FROM issued_status AS ist
JOIN
employees AS e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
GROUP BY 1 ,2
ORDER BY 6 DESC;
	

UPDATE users
SET role = 'ADMIN'
WHERE UPPER(role) IN ('EMERGENCY_WRITER', 'APPROVER');

UPDATE users
SET role = 'HOTEL_ADMIN'
WHERE UPPER(role) IN ('HOTEL_MANAGER', 'HOTELADMIN', 'HOTEL_ADMIN')
   OR username = 'hoteladmin';

UPDATE users
SET role = 'SYSTEM_ADMIN'
WHERE username = 'sysadmin';

UPDATE users
SET role = 'ADMIN'
WHERE username IN ('writer', 'approver');

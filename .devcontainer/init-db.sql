-- Initialize MySQL database for Kitchensink application

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS kitchensink CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE kitchensink;

-- Grant privileges to kitchensink user
GRANT ALL PRIVILEGES ON kitchensink.* TO 'kitchensink'@'%';
FLUSH PRIVILEGES;

-- Create member table (Spring Boot will handle this via Hibernate, but this is for reference)
-- CREATE TABLE IF NOT EXISTS member (
--     id BIGINT AUTO_INCREMENT PRIMARY KEY,
--     name VARCHAR(25) NOT NULL,
--     email VARCHAR(255) NOT NULL UNIQUE,
--     phone_number VARCHAR(12) NOT NULL,
--     CONSTRAINT unique_email UNIQUE (email)
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Sample data (optional - uncomment to add test data)
-- INSERT INTO member (name, email, phone_number) VALUES 
--     ('John Doe', 'john.doe@example.com', '555-1234'),
--     ('Jane Smith', 'jane.smith@example.com', '555-5678')
-- ON DUPLICATE KEY UPDATE name=VALUES(name);

SELECT 'Database initialization completed successfully!' AS message;

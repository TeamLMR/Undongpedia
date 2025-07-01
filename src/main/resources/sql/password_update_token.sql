CREATE TABLE password_update_token
(
    token_no    BIGINT AUTO_INCREMENT PRIMARY KEY,
    member_no   BIGINT       NOT NULL,
    token       VARCHAR(255) NOT NULL,
    expiry_date TIMESTAMP    NOT NULL,
    used        BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (member_no) REFERENCES member (member_no)
); 
ALTER TABLE complaints
    ADD COLUMN rejection_comment TEXT NULL AFTER closure_comment,
    ADD COLUMN assignee_id BIGINT NULL AFTER processed_by;

ALTER TABLE complaints
    ADD CONSTRAINT fk_complaint_assignee FOREIGN KEY (assignee_id) REFERENCES users(id);

CREATE INDEX idx_complaints_status ON complaints(status);
CREATE INDEX idx_complaints_assignee ON complaints(assignee_id);

CREATE TABLE complaint_timelines (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    complaint_id BIGINT NOT NULL,
    action VARCHAR(32) NOT NULL,
    comment TEXT NULL,
    actor_id BIGINT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_timeline_complaint FOREIGN KEY (complaint_id) REFERENCES complaints(id),
    CONSTRAINT fk_timeline_actor FOREIGN KEY (actor_id) REFERENCES users(id)
);

CREATE INDEX idx_timeline_complaint_created ON complaint_timelines(complaint_id, created_at);

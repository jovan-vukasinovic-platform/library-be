CREATE TABLE books (
    id              BIGSERIAL PRIMARY KEY,
    title           VARCHAR(255) NOT NULL,
    author          VARCHAR(255) NOT NULL,
    published_year  INTEGER,
    status          VARCHAR(20) NOT NULL DEFAULT 'DOSTUPNO',
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP
);

CREATE INDEX idx_books_status ON books (status);

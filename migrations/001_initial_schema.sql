-- Helpdesk Schema — INITIAL (BROKEN VERSION)
-- Students: this file has intentional problems. Fix them.
-- Reference: the ER diagram in the assignment-question.md

-- Setup: enable UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Organizations
CREATE TABLE organizations (
  id         SERIAL PRIMARY KEY,              -- TODO: should use UUID
  name       VARCHAR(100),                    -- TODO: missing NOT NULL
  plan       TEXT,                            -- TODO: no CHECK for allowed values
  created_at TIMESTAMP                        -- TODO: wrong type, missing DEFAULT
);

-- Agents
CREATE TABLE agents (
  id             SERIAL PRIMARY KEY,           -- TODO: should use UUID
  name           VARCHAR(100),                 -- TODO: missing NOT NULL
  email          TEXT,                         -- TODO: missing NOT NULL and UNIQUE
  role           TEXT,                         -- TODO: no CHECK for allowed values
  org_id         INTEGER REFERENCES organizations(id),  -- TODO: wrong type, missing NOT NULL, missing ON DELETE
  created_at     TIMESTAMP,                   -- TODO: wrong type, missing DEFAULT
  deactivated_at TIMESTAMP                    -- TODO: nullable is correct but wrong type, should be TIMESTAMPTZ
);

-- Tickets
CREATE TABLE tickets (
  id           SERIAL PRIMARY KEY,             -- TODO: should use UUID
  subject      VARCHAR(200),                   -- TODO: missing NOT NULL
  body         TEXT,                           -- nullable is correct
  priority     TEXT,                           -- TODO: no CHECK for low|medium|high|urgent
  status       TEXT DEFAULT 'open',            -- TODO: missing NOT NULL, missing CHECK
  org_id       INTEGER REFERENCES organizations(id),  -- TODO: wrong type, missing NOT NULL, missing ON DELETE
  created_by   INTEGER REFERENCES agents(id),  -- TODO: wrong type, missing NOT NULL, missing ON DELETE
  assignee_id  INTEGER REFERENCES agents(id),  -- TODO: wrong type, missing ON DELETE (SET NULL)
  created_at   TIMESTAMP DEFAULT NOW(),        -- TODO: should be TIMESTAMPTZ
  resolved_at  TIMESTAMP                       -- TODO: nullable is correct but wrong type, should be TIMESTAMPTZ
);

-- Comments
CREATE TABLE comments (
  id         SERIAL PRIMARY KEY,              -- TODO: should use UUID
  ticket_id  INTEGER REFERENCES tickets(id),  -- TODO: wrong type, missing NOT NULL, missing ON DELETE
  author_id  INTEGER REFERENCES agents(id),   -- TODO: wrong type, missing NOT NULL, missing ON DELETE
  body       TEXT,                            -- TODO: missing NOT NULL
  internal   TEXT DEFAULT 'false',            -- TODO: wrong type, should be BOOLEAN
  created_at TIMESTAMP DEFAULT NOW()          -- TODO: should be TIMESTAMPTZ
);

-- Rejected shape: tags stored as array on tickets
-- TODO: Remove this and create Tag + TicketTag tables instead
ALTER TABLE tickets ADD COLUMN tags TEXT[];

-- NOTE: Tag and TicketTag tables are MISSING entirely.
-- Students must add them based on the ER diagram.

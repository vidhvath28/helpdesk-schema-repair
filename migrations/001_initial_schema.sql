-- Helpdesk Schema: repaired to match the ER diagram.
-- Tables are created in dependency order: a table can only reference tables that already exist.

-- gen_random_uuid() (built in from PostgreSQL 13; pgcrypto provides it on older versions)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Organizations
CREATE TABLE organizations (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  name       TEXT        NOT NULL,
  plan       TEXT        NOT NULL CHECK (plan IN ('starter','pro','enterprise')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Agents
CREATE TABLE agents (
  id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  name           TEXT        NOT NULL,
  email          TEXT        NOT NULL UNIQUE,
  role           TEXT        NOT NULL CHECK (role IN ('agent','supervisor','admin')),
  org_id         UUID        NOT NULL REFERENCES organizations(id) ON DELETE RESTRICT,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deactivated_at TIMESTAMPTZ  -- NULL means active
);

-- Tickets
CREATE TABLE tickets (
  id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  subject      TEXT        NOT NULL,
  body         TEXT,       -- optional
  priority     TEXT        NOT NULL CHECK (priority IN ('low','medium','high','urgent')),
  status       TEXT        NOT NULL DEFAULT 'open'
                           CHECK (status IN ('open','pending','resolved','closed')),
  org_id       UUID        NOT NULL REFERENCES organizations(id) ON DELETE RESTRICT,
  created_by   UUID        NOT NULL REFERENCES agents(id) ON DELETE RESTRICT,
  assignee_id  UUID        REFERENCES agents(id) ON DELETE SET NULL,  -- optional: unassigned
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  resolved_at  TIMESTAMPTZ  -- stays NULL until the ticket is resolved
);

-- Comments
CREATE TABLE comments (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_id  UUID        NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
  author_id  UUID        NOT NULL REFERENCES agents(id) ON DELETE RESTRICT,
  body       TEXT        NOT NULL,
  internal   BOOLEAN     NOT NULL DEFAULT FALSE,  -- TRUE = visible to agents only
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Tags (replaces the rejected tickets.tags TEXT[] column)
CREATE TABLE tags (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id    UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  name      TEXT NOT NULL,
  color_hex TEXT NOT NULL CHECK (color_hex ~ '^#[0-9A-Fa-f]{6}$'),
  UNIQUE (org_id, name)  -- one "billing" tag per organization
);

-- TicketTag: resolves the Ticket <-> Tag M:N and records who applied the tag, and when
CREATE TABLE ticket_tags (
  id        UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_id UUID        NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
  tag_id    UUID        NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
  added_by  UUID        NOT NULL REFERENCES agents(id) ON DELETE RESTRICT,
  added_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (ticket_id, tag_id)  -- a tag is applied to a ticket at most once
);

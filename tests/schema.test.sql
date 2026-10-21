-- pgTAP Schema Tests for Helpdesk Schema Repair
-- Run via: npm test (uses pg-tap runner)

BEGIN;
SELECT plan(36);

-- ============================================================
-- TABLE EXISTENCE TESTS
-- ============================================================
SELECT has_table('organizations', 'organizations table exists');
SELECT has_table('agents', 'agents table exists');
SELECT has_table('tickets', 'tickets table exists');
SELECT has_table('comments', 'comments table exists');
SELECT has_table('tags', 'tags table exists');
SELECT has_table('ticket_tags', 'ticket_tags table exists');

-- ============================================================
-- COLUMN TYPE TESTS
-- ============================================================
SELECT col_type_is('organizations', 'id', 'uuid', 'organizations.id is UUID');
SELECT col_type_is('agents', 'id', 'uuid', 'agents.id is UUID');
SELECT col_type_is('tickets', 'id', 'uuid', 'tickets.id is UUID');
SELECT col_type_is('comments', 'id', 'uuid', 'comments.id is UUID');
SELECT col_type_is('tags', 'id', 'uuid', 'tags.id is UUID');
SELECT col_type_is('ticket_tags', 'id', 'uuid', 'ticket_tags.id is UUID');

SELECT col_type_is('agents', 'org_id', 'uuid', 'agents.org_id is UUID FK');
SELECT col_type_is('tickets', 'org_id', 'uuid', 'tickets.org_id is UUID FK');
SELECT col_type_is('tickets', 'created_by', 'uuid', 'tickets.created_by is UUID FK');
SELECT col_type_is('tickets', 'assignee_id', 'uuid', 'tickets.assignee_id is UUID FK');

SELECT col_type_is('organizations', 'created_at', 'timestamp with time zone', 'organizations.created_at is TIMESTAMPTZ');
SELECT col_type_is('tickets', 'created_at', 'timestamp with time zone', 'tickets.created_at is TIMESTAMPTZ');
SELECT col_type_is('comments', 'created_at', 'timestamp with time zone', 'comments.created_at is TIMESTAMPTZ');

SELECT col_type_is('comments', 'internal', 'boolean', 'comments.internal is BOOLEAN not TEXT');

-- ============================================================
-- NOT NULL TESTS
-- ============================================================
SELECT col_not_null('organizations', 'name', 'organizations.name is NOT NULL');
SELECT col_not_null('agents', 'name', 'agents.name is NOT NULL');
SELECT col_not_null('agents', 'email', 'agents.email is NOT NULL');
SELECT col_not_null('agents', 'org_id', 'agents.org_id is NOT NULL');
SELECT col_not_null('tickets', 'subject', 'tickets.subject is NOT NULL');
SELECT col_not_null('tickets', 'status', 'tickets.status is NOT NULL');
SELECT col_not_null('tickets', 'org_id', 'tickets.org_id is NOT NULL');
SELECT col_not_null('tickets', 'created_by', 'tickets.created_by is NOT NULL');
SELECT col_not_null('comments', 'body', 'comments.body is NOT NULL');
SELECT col_not_null('comments', 'ticket_id', 'comments.ticket_id is NOT NULL');
SELECT col_not_null('comments', 'author_id', 'comments.author_id is NOT NULL');

-- ============================================================
-- NULLABLE TESTS (should be nullable)
-- ============================================================
SELECT col_is_null('tickets', 'assignee_id', 'tickets.assignee_id is nullable');
SELECT col_is_null('tickets', 'resolved_at', 'tickets.resolved_at is nullable');
SELECT col_is_null('agents', 'deactivated_at', 'agents.deactivated_at is nullable');

-- ============================================================
-- COLUMN ABSENCE TESTS (rejected shape must be removed)
-- ============================================================
SELECT hasnt_column('tickets', 'tags', 'tickets.tags array column must be removed');

-- ============================================================
-- UNIQUE CONSTRAINT TESTS
-- ============================================================
SELECT col_is_unique('agents', 'email', 'agents.email is UNIQUE');

SELECT * FROM finish();
ROLLBACK;

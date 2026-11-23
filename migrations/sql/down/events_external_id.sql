-- Backfill null created_by to an existing staff user before restoring NOT NULL
UPDATE events
SET created_by = (SELECT id FROM staff_users ORDER BY created_at ASC LIMIT 1)
WHERE created_by IS NULL;

-- Remove any remaining orphaned events if no staff user exists
DELETE FROM events WHERE created_by IS NULL;

ALTER TABLE events ALTER COLUMN created_by SET NOT NULL;
ALTER TABLE events DROP COLUMN IF EXISTS external_id;

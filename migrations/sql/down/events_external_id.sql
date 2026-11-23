-- NOTE: re-adding NOT NULL fails if synced events (created_by IS NULL) exist.
-- Delete or reassign those rows before downgrading.
ALTER TABLE events ALTER COLUMN created_by SET NOT NULL;
ALTER TABLE events DROP COLUMN IF EXISTS external_id;

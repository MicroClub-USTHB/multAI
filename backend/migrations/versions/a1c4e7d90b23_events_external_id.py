"""events_external_id

Revision ID: a1c4e7d90b23
Revises: 27efe448f970
Create Date: 2026-11-23 23:55:00.000000

"""

from typing import Sequence, Union

from migrations.helper import run_sql_down, run_sql_up


revision: str = "a1c4e7d90b23"
down_revision: Union[str, Sequence[str], None] = "27efe448f970"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    run_sql_up("events_external_id")


def downgrade() -> None:
    run_sql_down("events_external_id")

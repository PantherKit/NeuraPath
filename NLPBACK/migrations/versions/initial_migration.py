"""initial migration

Revision ID: 0001
Revises: 
Create Date: 2023-11-01

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = '0001'
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    # Tabla users
    op.create_table('users',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('username', sa.String(), nullable=True),
        sa.Column('email', sa.String(), nullable=True),
        sa.Column('hashed_password', sa.String(), nullable=True),
        sa.Column('is_active', sa.Boolean(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=True),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_users_email'), 'users', ['email'], unique=True)
    op.create_index(op.f('ix_users_id'), 'users', ['id'], unique=False)
    op.create_index(op.f('ix_users_username'), 'users', ['username'], unique=True)

    # Tabla careers
    op.create_table('careers',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('nombre', sa.String(), nullable=True),
        sa.Column('universidad', sa.String(), nullable=True),
        sa.Column('descripcion', sa.Text(), nullable=True),
        sa.Column('ubicacion', sa.String(), nullable=True),
        sa.Column('area_conocimiento', sa.String(), nullable=True),
        sa.Column('nivel_estudio', sa.String(), nullable=True),
        sa.Column('duracion', sa.String(), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_careers_id'), 'careers', ['id'], unique=False)
    op.create_index(op.f('ix_careers_nombre'), 'careers', ['nombre'], unique=False)
    op.create_index(op.f('ix_careers_ubicacion'), 'careers', ['ubicacion'], unique=False)
    op.create_index(op.f('ix_careers_universidad'), 'careers', ['universidad'], unique=False)
    op.create_index(op.f('ix_careers_area_conocimiento'), 'careers', ['area_conocimiento'], unique=False)

    # Tabla mbti_profiles
    op.create_table('mbti_profiles',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('user_id', sa.Integer(), nullable=True),
        sa.Column('mbti_code', sa.String(length=4), nullable=True),
        sa.Column('mbti_vector', postgresql.JSON(astext_type=sa.Text()), nullable=True),
        sa.Column('mbti_weights', postgresql.JSON(astext_type=sa.Text()), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=True),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_mbti_profiles_id'), 'mbti_profiles', ['id'], unique=False)

    # Tabla mi_profiles
    op.create_table('mi_profiles',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('user_id', sa.Integer(), nullable=True),
        sa.Column('mi_scores', postgresql.JSON(astext_type=sa.Text()), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=True),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_mi_profiles_id'), 'mi_profiles', ['id'], unique=False)

    # Tabla career_matches
    op.create_table('career_matches',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('user_id', sa.Integer(), nullable=True),
        sa.Column('career_id', sa.Integer(), nullable=True),
        sa.Column('match_score', sa.Float(), nullable=True),
        sa.Column('timestamp', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=True),
        sa.Column('mbti_profile_id', sa.Integer(), nullable=True),
        sa.Column('mi_profile_id', sa.Integer(), nullable=True),
        sa.ForeignKeyConstraint(['career_id'], ['careers.id'], ),
        sa.ForeignKeyConstraint(['mbti_profile_id'], ['mbti_profiles.id'], ),
        sa.ForeignKeyConstraint(['mi_profile_id'], ['mi_profiles.id'], ),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_career_matches_id'), 'career_matches', ['id'], unique=False)

    # Tabla de asociación user_career_association
    op.create_table('user_career_association',
        sa.Column('user_id', sa.Integer(), nullable=False),
        sa.Column('career_id', sa.Integer(), nullable=False),
        sa.ForeignKeyConstraint(['career_id'], ['careers.id'], ),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
        sa.PrimaryKeyConstraint('user_id', 'career_id')
    )


def downgrade():
    # Eliminar tablas en orden inverso
    op.drop_table('user_career_association')
    op.drop_index(op.f('ix_career_matches_id'), table_name='career_matches')
    op.drop_table('career_matches')
    op.drop_index(op.f('ix_mi_profiles_id'), table_name='mi_profiles')
    op.drop_table('mi_profiles')
    op.drop_index(op.f('ix_mbti_profiles_id'), table_name='mbti_profiles')
    op.drop_table('mbti_profiles')
    op.drop_index(op.f('ix_careers_universidad'), table_name='careers')
    op.drop_index(op.f('ix_careers_ubicacion'), table_name='careers')
    op.drop_index(op.f('ix_careers_nombre'), table_name='careers')
    op.drop_index(op.f('ix_careers_id'), table_name='careers')
    op.drop_index(op.f('ix_careers_area_conocimiento'), table_name='careers')
    op.drop_table('careers')
    op.drop_index(op.f('ix_users_username'), table_name='users')
    op.drop_index(op.f('ix_users_id'), table_name='users')
    op.drop_index(op.f('ix_users_email'), table_name='users')
    op.drop_table('users') 
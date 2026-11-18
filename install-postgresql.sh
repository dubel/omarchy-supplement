#!/bin/bash

# Install and initialize PostgreSQL
set -e

echo "Installing PostgreSQL..."
if ! command -v psql &>/dev/null; then
    yay -S --noconfirm --needed postgresql
else
    echo "PostgreSQL package is already installed."
fi

# Check if the cluster is already initialized. /var/lib/postgres is mode 700
# (owned by postgres), so the check must run with elevated rights.
if ! sudo test -s /var/lib/postgres/data/PG_VERSION; then
    echo "Initializing PostgreSQL database..."
    sudo -u postgres initdb -D /var/lib/postgres/data --locale=C.UTF-8 --encoding=UTF8 --data-checksums
else
    echo "PostgreSQL data directory already initialized, skipping initdb..."
fi

# Start and enable PostgreSQL service
if ! systemctl is-active --quiet postgresql; then
    echo "Starting PostgreSQL service..."
    sudo systemctl start postgresql
fi

if ! systemctl is-enabled --quiet postgresql 2>/dev/null; then
    echo "Enabling PostgreSQL service..."
    sudo systemctl enable postgresql
fi

# Create a database user matching the current user if it doesn't exist
echo "Checking PostgreSQL user..."
if ! sudo -u postgres psql -tAc "SELECT 1 FROM pg_user WHERE usename='$USER'" 2>/dev/null | grep -q 1; then
    echo "Creating PostgreSQL user: $USER"
    sudo -u postgres createuser -d -s "$USER"
    echo "Created PostgreSQL superuser: $USER"
else
    echo "PostgreSQL user '$USER' already exists."
fi

# Create a default database for the user if it doesn't exist
if ! sudo -u postgres psql -lqt 2>/dev/null | cut -d \| -f 1 | grep -qw "$USER"; then
    echo "Creating default database: $USER"
    createdb "$USER" || sudo -u postgres createdb -O "$USER" "$USER"
    echo "Created default database: $USER"
else
    echo "Database '$USER' already exists."
fi

echo "PostgreSQL installation and setup complete!"
echo "You can now connect to PostgreSQL using: psql"

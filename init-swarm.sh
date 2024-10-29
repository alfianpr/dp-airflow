#!/bin/bash

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for required commands
for cmd in docker openssl; do
    if ! command_exists "$cmd"; then
        log "Error: $cmd is required but not installed."
        exit 1
    fi
done

# Generate Fernet key
generate_fernet_key() {
    python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
}

# Generate random string for Webserver secret key
generate_secret_key() {
    openssl rand -hex 32
}

# Create necessary directories
create_directories() {
    log "Creating Airflow directories..."
    mkdir -p dags logs plugins config
    chmod -R 777 dags logs plugins config
}

# Initialize Docker Swarm on manager node
init_swarm() {
    if ! docker info | grep -q "Swarm: active"; then
        log "Initializing Docker Swarm..."
        docker swarm init
        log "Docker Swarm initialized successfully"

        # Print join token for workers
        log "Worker join token:"
        docker swarm join-token worker -q
    else
        log "Docker Swarm is already initialized"
    fi
}

# Create environment file
create_env_file() {
    log "Creating .env file..."
    if [ ! -f .env ]; then
        FERNET_KEY=$(generate_fernet_key)
        WEBSERVER_SECRET_KEY=$(generate_secret_key)

        cat > .env << EOF
FERNET_KEY=$FERNET_KEY
WEBSERVER_SECRET_KEY=$WEBSERVER_SECRET_KEY
EOF
        log ".env file created successfully"
    else
        log ".env file already exists"
    fi
}

# Deploy Airflow stack
deploy_airflow() {
    log "Deploying Airflow stack..."
    docker stack deploy -c docker-compose.yml airflow
    log "Airflow stack deployed successfully"
}

# Main execution
main() {
    log "Starting Airflow cluster initialization..."

    create_directories
    init_swarm
    create_env_file
    deploy_airflow

    log "Initialization complete!"
    log "Airflow UI will be available at http://localhost:8080"
    log "Flower UI will be available at http://localhost:5555"
    log "Default credentials - username: admin, password: admin"
}

# Run main function
main

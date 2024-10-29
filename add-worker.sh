#!/bin/bash

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Check if required arguments are provided
if [ "$#" -ne 2 ]; then
    log "Usage: $0 <manager_ip> <join_token>"
    exit 1
fi

MANAGER_IP=$1
JOIN_TOKEN=$2

# Install Docker if not present
install_docker() {
    if ! command -v docker &> /dev/null; then
        log "Installing Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker $USER
        rm get-docker.sh
        log "Docker installed successfully"
    else
        log "Docker is already installed"
    fi
}

# Join the swarm
join_swarm() {
    if ! docker info | grep -q "Swarm: active"; then
        log "Joining Docker Swarm..."
        docker swarm join --token $JOIN_TOKEN $MANAGER_IP:2377
        log "Successfully joined the swarm"
    else
        log "Node is already part of a swarm"
    fi
}

# Main execution
main() {
    log "Starting worker node setup..."

    install_docker
    join_swarm

    log "Worker node setup complete!"
}

# Run main function
main

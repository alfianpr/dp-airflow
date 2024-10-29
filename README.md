# dp-airflow

This repository provides a comprehensive setup for deploying an Apache Airflow cluster using Docker Swarm. This setup includes all necessary Docker Compose files, initialization scripts, configuration files, and helper scripts to streamline deployment and management of the Airflow cluster.

## Features

- **Scalable Architecture**: Supports dynamic addition and removal of worker nodes.
- **High Availability**: Core components (webserver, scheduler, database, and Redis) are deployed on manager nodes.
- **Monitoring**: Includes Flower for monitoring Celery workers.
- **Secure Configuration**: Uses Fernet key encryption and webserver secret key for secure setup.
- **Persistent Storage**: PostgreSQL data is stored in Docker volumes.

## Prerequisites

- Docker and Docker Compose installed on each node
- Docker Swarm initialized on manager node
- Ensure required ports are open between nodes (2377/tcp, 7946/tcp, 7946/udp, 4789/udp)

## Project Structure

\`\`\`plaintext
.
├── docker-compose.yml         # Main Docker Compose file for Airflow services
├── init-swarm.sh              # Script to initialize Docker Swarm and deploy Airflow stack
├── add-worker.sh              # Script to add worker nodes to the Swarm cluster
├── config/
│   └── airflow.cfg            # Custom Airflow configuration file
├── dags/                      # Directory for Airflow DAGs
├── logs/                      # Directory for Airflow logs
└── plugins/                   # Directory for Airflow plugins
\`\`\`

## Setup Guide

### 1. Clone the Repository
\`\`\`bash
git clone https://github.com/alfianpr/dp-airflow.git
cd dp-airflow
\`\`\`

### 2. Make Scripts Executable
\`\`\`bash
chmod +x init-swarm.sh add-worker.sh
\`\`\`

### 3. Initialize Docker Swarm and Deploy Airflow Stack
Run the following command on the manager node:
\`\`\`bash
./init-swarm.sh
\`\`\`

This script performs the following actions:

- Initializes Docker Swarm
- Creates necessary directories
- Generates a \`.env\` file with a Fernet key and webserver secret key
- Deploys the Airflow stack

After the setup completes, access the services at:

- **Airflow UI**: [http://localhost:8080](http://localhost:8080)
- **Flower UI**: [http://localhost:5555](http://localhost:5555)

### 4. Add Worker Nodes to the Swarm
On each worker node, use the following command, replacing \`<manager_ip>\` and \`<join_token>\` with the IP address of the manager and the join token provided by the \`init-swarm.sh\` script:
\`\`\`bash
./add-worker.sh <manager_ip> <join_token>
\`\`\`

## Environment Configuration

The \`.env\` file contains the following environment variables:

- \`FERNET_KEY\`: Encryption key for sensitive data
- \`WEBSERVER_SECRET_KEY\`: Secret key for web server authentication

These variables are generated automatically during initialization.

## Scaling the Cluster

The worker service is set to \`mode: global\`, meaning it automatically runs on all worker nodes. To scale the number of workers:

1. Add additional nodes to the Swarm.
2. Use the \`add-worker.sh\` script to join them to the cluster.

## Default Credentials

- Username: \`admin\`
- Password: \`admin\`

## Additional Notes

1. **Network Configuration**: Ensure security group and firewall rules allow necessary ports between nodes.
2. **Resource Allocation**: Ensure sufficient resources (CPU, memory) on each node for optimal performance.
3. **Monitoring & Logging**: Consider setting up external monitoring solutions for enhanced observability.

---

## License

This project is licensed under the MIT License.

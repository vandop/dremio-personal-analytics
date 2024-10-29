# dremio-personal-analytics
Dremio and all dependencies to setup self-analytics

# Setting Up MinIO, Nessie, and Dremio on Your Local Machine

This guide provides step-by-step instructions to set up a local data lakehouse environment using **MinIO**, **Nessie**, and **Dremio** with Docker and Docker Compose.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation Steps](#installation-steps)
    - [1. Install Docker and Docker Compose](#1-install-docker-and-docker-compose)
    - [2. Clone this Repository](#2-clone-this-repository)
    - [3. Start the Services](#3-start-the-services)
    - [4. Configure MinIO](#4-configure-minio)
    - [5. Configure Nessie](#5-configure-nessie)
    - [6. Configure Dremio](#6-configure-dremio)
    - [7. Verify the Setup](#7-verify-the-setup)
    - [8. Configure Nessie Source in Dremio Using MinIO](#8-configure-nessie-source-in-dremio-using-minio)
    - [9. Test Writing to the Nessie Source](#9-test-writing-to-the-nessie-source)

---

## Prerequisites

- **Docker** installed on your machine.
- **Docker Compose** installed.

## Installation Steps

### 1. Install Docker and Docker Compose

- **Docker**: [Get Docker](https://docs.docker.com/get-docker/)
- **Docker Compose**: [Install Docker Compose](https://docs.docker.com/compose/install/)

### 2. Clone this Repository

Clone the repository containing the `docker-compose.yml` file.

```sh
git clone <repository-url>
cd <repository-directory>

### 3. Start the Services

Navigate to the directory containing the `docker-compose.yml` file and start the services using Docker Compose.

```sh
docker-compose up -d
```

This command will start MinIO, Nessie, and Dremio services in detached mode.

### 4. Configure MinIO

Access the MinIO console by navigating to `http://localhost:9000` in your web browser. Use the default credentials to log in:

- **Username**: `admin`
- **Password**: `password`

Create a new bucket named `datalake`.

### 5. Configure Nessie

Access the Nessie UI by navigating to `http://localhost:19120` in your web browser. Use the default settings to initialize the repository.

### 6. Configure Dremio

Access the Dremio UI by navigating to `http://localhost:9047` in your web browser. Follow the setup wizard to complete the initial configuration.

### 7. Verify the Setup

Ensure all services are running correctly by checking their respective UIs:

- **MinIO**: `http://localhost:9000`
- **Nessie**: `http://localhost:19120`
- **Dremio**: `http://localhost:9047`

You should be able to interact with each service without issues.

### 8. Configure Nessie Source in Dremio Using MinIO

To configure Nessie as a source in Dremio using MinIO, follow these steps:

1. **Access Dremio UI**: Navigate to `http://localhost:9047` and log in if you haven't already.

2. **Add a New Source**:
    - Click on the `+` icon next to `Sources` in the left-hand menu.
    - Select `Nessie` from the list of available sources.

3. **Configure the Nessie Source**:
    - **Name**: Enter a name for the Nessie source, e.g., `NessieSource`.
    - **Nessie Server URL**: Enter `http://nessie:19120/api/v2`.
    - **Authentication Type**: Select `None` (or configure as needed).
 
    - Go to **Storage** inside Nessie configuratoin
    - **AWS root patht**: Enter `datalake`.
    - **AWS Access Key**: Enter `admin`.
    - **AWS Secret Key**: Enter `password`.
    - User **Other** set the followings Connection Properties:
    - **fs.s3a.path.style.access**: Enter `true`
    - **fs.s3a.endpoint**: Enter `minio:9000`
    - **dremio.s3.compat**: Enter `true`

5. **Save the Configuration**: Click `Save` to add the Nessie source.

6. **Verify the Source**:
    - Navigate to the `Sources` section in Dremio.
    - Click on the newly created `NessieSource` to ensure it connects and displays the contents of the `datalake` bucket.

This completes the configuration of Nessie as a source in Dremio using MinIO.

### 9. Test Writing to the Nessie Source

To verify that writing to the Nessie source is working correctly, follow these steps:

1. **Access Dremio SQL Editor**:
    - Navigate to `http://localhost:9047` and log in if you haven't already.
    - Click on the `SQL Editor` tab at the top of the page.

2. **Create a New Table**:
    - In the SQL Editor, enter the following SQL command to create a new table in the `NessieSource`:

    ```sql
    CREATE TABLE NessieSource.datalake.people (
        id INT,
        first_name VARCHAR,
        last_name VARCHAR,
        age INT
    ) PARTITION BY (truncate(1, last_name));
    ```

3. **Execute the Command**:
    - Click the `Run` button to execute the SQL command.

4. **Verify the Table Creation**:
    - Navigate to the `Sources` section in Dremio.
    - Click on `NessieSource` and then `datalake` to ensure the `people` table has been created successfully.

This step confirms that you can write to the Nessie source configured in Dremio using MinIO.
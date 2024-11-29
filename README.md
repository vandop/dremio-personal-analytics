# dremio-personal-analytics
Dremio and all dependencies to setup self-analytics

# Setting Up MinIO and Dremio on Your Local Machine

This guide provides step-by-step instructions to set up a local data lakehouse environment using **MinIO** as **Nessie** or **Amazon S3** and **Dremio** with Docker and Docker Compose.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation Steps](#installation-steps)
    - [1. Install Docker and Docker Compose](#1-install-docker-and-docker-compose)
    - [2. Clone this Repository](#2-clone-this-repository)
    - [3. Start the Services](#3-start-the-services)
    - [4. Configure MinIO](#4-configure-minio)
    - [5. Configure Dremio](#5-configure-dremio)
    - [6. Verify the Setup](#6-verify-the-setup)
    - [7. Configure Sources in Dremio Using MinIO](#7-configure-sources-in-dremio-using-minio)
        - [7.1. Configure Nessie Source in Dremio using MinIO](#71-configure-nessie-source-in-dremio-using-minio)
        - [7.2. Configure S3 Source in Dremio using MinIO](#72-configure-amazon-s3-source-in-dremio-using-minio)
    - [8. Test Writing to the Nessie Source](#9-test-writing-to-the-nessie-source)
- [Additional Resources](#additional-resources)

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
```

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

### 5. Configure Dremio

Access the Dremio UI by navigating to `http://localhost:9047` in your web browser. Follow the setup wizard to complete the initial configuration.

### 6. Verify the Setup

Ensure all services are running correctly by checking their respective UIs:

- **MinIO**: `http://localhost:9000`
- **Dremio**: `http://localhost:9047`

You should be able to interact with each service without issues.

### 7. Configure Sources in Dremio Using MinIO

- To configure Nessie as a source in Dremio using MinIO, follow [7.1. Configure Nessie Source in Dremio using MinIO](#71-configure-nessie-source-in-dremio-using-minio).

- To configure Amazon S3 source as a source in Dremio, follow [7.2. Configure S3 Source in Dremio using MinIO](#72-configure-amazon-s3-source-in-dremio-using-minio).

#### 7.1. Configure Nessie Source in Dremio using MinIO

1. **Access Dremio UI**: Navigate to `http://localhost:9047` and log in if you haven't already.

2. **Add a New Source**:
    - Click on the `+` icon next to `Sources` in the left-hand menu.
    - Select `Nessie` from the list of available sources.

3. **Configure the Nessie Source**:
    - **Name**: Enter a name for the Nessie source, e.g., `NessieSource`.
    - **Nessie Server URL**: Enter `http://nessie:19120/api/v2`.
    - **Authentication Type**: Select `None` (or configure as needed).
 
    - Go to **Storage** inside Nessie configuration
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

#### 7.2. Configure Amazon S3 Source in Dremio Using MinIO

1. **Access Dremio UI**: Navigate to `http://localhost:9047` and log in if you haven't already.

2. **Add a New Source**:
    - Click on the `+` icon next to `Sources` in the left-hand menu.
    - Select `Amazon S3` from the list of available sources.

3. **Configure the Nessie Source**:
    - **Name**: Enter a name for the S3 source source, e.g., `S3Source`.
    - **Authentication Type**: Select `AWS Access Key`.
    - **AWS Access Key**: Enter `admin`.
    - **AWS Secret Key**: Enter `password`.
    - **Disable** the option `Encrypt connection`

    - Go to `Advanced Options` tab and set the following **Connection Properties**:
        - **fs.s3a.path.style.access**: Enter `true`
        - **fs.s3a.endpoint**: Enter `minio:9000`
        - **dremio.s3.compat**: Enter `true`
        
    - In `Cache Options` **disable** the option `Enable local caching when possible`
    
This completes the configuration of Amazon S3 as a source in Dremio using MinIO.

### 8. Test Writing to the Source

To verify that writing to the source is working correctly, follow these steps and in `<source_name>` replace with `NessieSource` or `S3Source` accordingly:

1. **Access Dremio SQL Editor**:
    - Navigate to `http://localhost:9047` and log in if you haven't already.
    - Click on the `SQL Editor` tab at the top of the page.

2. **Create a New Table**:
    - In the SQL Editor, enter the following SQL command to create a new table in the source:

    ```sql
    CREATE TABLE <source_name>.datalake.people (
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
    - Click on `<source_name>` and then `datalake` to ensure the `people` table has been created successfully.

This step confirms that you can write to the source configured in Dremio using MinIO.

## Additional Resources

For more information and advanced configurations, refer to the following resources:

- [Introduction to Dremio, Nessie, and Apache Iceberg on Your Laptop](https://www.dremio.com/blog/intro-to-dremio-nessie-and-apache-iceberg-on-your-laptop/)
- [Setup a dbt Project](SETUP_DBT.md)

These resources provide deeper insights and extended functionalities that you can explore to enhance your data lakehouse setup.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

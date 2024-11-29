# Setup a dbt Project
This guide provides step-by-step instructions to create a dbt project.

## Table of Contents

- [Requirements](#requirements)
- [Procedure](#procedure)

## Requirements
Have a connectable Dremio instance running, with a configured source that is writable.

## Procedure
1. Run the command dbt init <project_name> 
2. Configure the project
    
    a. Select `dremio` as a database to use
    ```
    Which database would you like to use?
        [1] dremio
    Enter a number: 1
    ```
    b. Select one of these options to generate a profile for the project:

    - `dremio_cloud` for working with Dremio Cloud
    - `software_with_username_password` for working with a Dremio Software cluster and authenticating to the cluster with a username and a password
    - `software_with_pat` for working with a Dremio Software cluster and authenticating to the cluster with a personal access token

    In this example, the project was configured in a local Dremio instance, so option 2 was selected.
    ```
    [1] dremio_cloud
    [2] software_with_username_password
    [3] software_with_pat
    Desired cloud of software with password or software with pat option (enter a number): 2
    ```
    c. Continue configuring, filling the information accordingly
    ```
    software_host: dremio
    port [9047]: [enter]
    user (username): dremio
    password (password): dremio123
    use_ssl (use encrypted connection) [False]: [enter]
    object_storage_source (object storage source for seeds, tables, etc. [dbt alias: datalake]) [$scratch]: <source_name>
    object_storage_path (object storage path [dbt alias: schema]) [no_schema]: <folder_inside_source>
    dremio_space (space for creating views [dbt alias: database]) [@user]: <space_from_your_dremio_instance>
    dremio_space_folder (dremio space folder [dbt alias: root_path]) [no_schema]: [enter]
    threads (1 or more) [1]: [enter]
    ```
    d. After setting up all, there should be a message 
    > Profile <project_name> written to /Users/\<user>/.dbt/profiles.yml using target’s *profile_template.yml* and your supplied values. Run `dbt debug` to validate the connection.

3. Perform `dbt run`

4. Check in the Dremio instance that the views of the models *my_first_dbt_model* and *my_second_dbt_model* were created in the space defined in step **c**

# docker-ci-pipeline

### Steps to deploy

##### 1. Create Environment in Github:

Go to repository's Settings --> Ennvironments --> New environment

##### 2. Clone this repository:

```bash
git clone https://github.com/Chieme01/docker-ci-pipeline.git
```

##### 3. Create your Azure Container Registry (ACR) and other foundational resources in azure

Review and apply the terraform code in this repository:

```bash
terraform plan
terraform apply
```

##### 4. Store ACR's name in environment secret named as "ACR_NAME".

Go to repository's Settings --> Ennvironments --> Select environment --> Add environment secret 

##### 5. Create Managed Identity in Azure

Azure portal --> Managed Identity --> Create

##### 6. Add Federated Credentials to the Manged Identity

Azure portal --> Managed Identity --> Select Managed Identity --> Settings --> Federated Credentials -- Add Credentials --> Select "Github Actions deploying Azure resources" scenario 

```
Organization = <YOUR GITHUB ORGANIZATION OR PROFILE NAME>
Repository = <YOUR GITHUB REPOSITORY NAME>
Entity = Environment
Environment = <YOUR GITHUB ENVIRONMENT NAME FROM STEP 1>
Name = <NAME OF THE FEDERATED CREDENTIAL>
```
##### 7.  Assign roles "Container Registry Repository Contributor" and "AcrPush" to the Managed Identity

##### 8. Create Environment secrets for the Managed-Identity secrets:

Azure portal --> Managed Identity --> Select Managed Identity --> Settings --> Properties --> Copy Tenant Id, Client Id and Subscription Id

Go to Github repository's Settings --> Ennvironments --> Select environment --> Add environment secret --> Create secrets for: AZURE_CLIENT_ID, AZURE_TENANT_ID and AZURE_SUBSCRIPTION_ID

##### 9. Create Synk Token

Sign up for snyk at https://snyk.io/login

Synk Web UI --> profile avatar --> Account Settings --> Personal Access Tokens --> Generate new token

##### 10. Store Snyk Token in environment secret named as "SNYK_TOKEN".

Go to repository's Settings --> Ennvironments --> Select environment --> Add environment secret

##### 11. Create Personal Access Token (PAT)

Github Profile --> Settings --> Developer settings -->  Personal access tokens --> Fine-grained tokens --> Generate new token

Add "Contents" permission for "Read and write".

##### 12. Store Personal Access Token (PAT) as ennvironment secrets named "GITOPS_PAT".

Go to repository's Settings --> Ennvironments --> Select environment --> Add environment secret


### Understanding the commands in the Dockerfile.
In modules/docker/Dockerfile;

- WORKDIR /app : If you don't set a workdir, Docker defaults to the root directory (/). If you copy your app there, your code gets mixed in with system folders like /etc, /bin, and /var. If the folder /app doesn't exist yet, Docker will create it for you automatically. You don't need to run RUN mkdir /app

- RUN apt-get install -y
- --no-install-recommends \ : By default, apt installs "recommended" packages (like documentation or extra fonts) that you don't actually need to run code. This can save 50MB to 200MB of image size.

- build-essential \ : If your requirements.txt has a Python library written in C (like pandas, numpy, or psycopg2), the container needs these tools to "build" that library during the pip install phase.

- rm -rf /var/lib/apt/lists/* : When you run apt-get update, it creates a database of packages in /var/lib/apt/lists/. Once the installation is finished, you don't need that database anymore. By deleting it in the same RUN command, you ensure that those files aren't saved into the Docker image layer. Further reducing the size of your image.

- RUN pip install 
- --user : This flag installs your Python packages into the user's local directory (usually ~/.local) instead of the system-wide site-packages (like /usr/local/lib/python3.11/). By using --user, we know exactly where all the new libraries are: /root/.local. 
It allows the application to run as a non-root user while still having access to its libraries in its own home directory.

- --no-cache-dir : This flag tells pip to delete the downloaded files as soon as the installation is finished. It ensures that the "trash" never gets saved into your Docker layer.

### Why use multiple Stages in the Docker build
In Docker, deleted files still take up space if they were created in a previous layer.

In Single-Stage: If you run apt-get install build-essential in one line and then apt-get remove in another, that 100MB of tools is still inside the image's history. It's just hidden.

In Multi-Stage: The second stage starts with a fresh, blank slate (a new FROM line). When you COPY --from=builder, you are only picking up the "finished fruit" and leaving the "peels and stems" behind in a stage that is eventually discarded.

### Why separate RUN commands
In Docker, every line in your Dockerfile creates a layer. If a line (and all the lines above it) hasn't changed since the last build, it skips that step and uses a cached version.

By separating the system tools (apt-get) from the Python libraries (pip), it makes your local development and your GitHub Actions pipeline significantly faster.

- RUN groupadd -r appgroup && useradd -r -g appgroup appuser : It creates a dedicated, limited-power user to run your application. Even though a container is "isolated," it shares the same Kernel as the host machine (the EC2 instance or the Azure VM).
If a process is running as root inside the container and manages to "break out" (via a kernel exploit), it is now root on the actual physical host.
By switching to a non-privileged user (appuser), even if a hacker takes over your app, they are trapped in a "low-privilege" account. They can't install new software, change system files, or easily attack the host.

### Notes
For more examples, including how to limit scans to only high-severity issues, monitor images for newly disclosed vulnerabilities in Snyk and fail PR checks for new vulnerabilities, see https://github.com/snyk/actions/

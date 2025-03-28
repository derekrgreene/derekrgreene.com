<h1 align="center">Hi 👋, I'm Derek R. Greene</h1>
<p align="center"><a href="https://www.buymeacoffee.com/derekgreene"> <img align="center" src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" height="50" width="210" alt="derekgreene" /></a></p><br><br>


# Deploy with Docker

## Prerequisites
- Docker
- Docker Compose
- Git

## Setup Steps

### 1. Clone the Repository
```bash
git clone https://github.com/derekgreene11/derekrgreene.com.git
cd derekrgreene.com
```

### 2. Create Environment File
Create a `.env` file in the project root directory with the following variables:
```
GITHUB_SECRET=<your_github_webhook_secret>
SUDO_PASSWORD=<your_sudo_password>
DBHOST=<database_host>
DBUSER=<database_username>
DBPW=<database_password>
DB=<database_name>
```

### 3. Copy .env to EngDB Project
```bash
cp .env flask_proj/.env
```

### 4. Build and Initialize Docker Containers
```bash
docker-compose build
docker-compose up -d
```

### 5. Database User Setup

#### Find MySQL Container Name
```bash
docker ps
```
Look for the container with MySQL image.

#### Create Database User
Replace `<mysql-container-id>`, `<username>`, and `<password>` with your specific values:
```bash
sudo docker exec -it <mysql-container-id> mysql -u root -p
```

Once in MySQL, run:
```sql
CREATE USER '<username>'@'%' IDENTIFIED BY '<password>';
GRANT ALL PRIVILEGES ON *.* TO '<username>'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EXIT;
```

### 6. Stopping and Restarting

#### Stop Containers
```bash
docker-compose down
```

#### Restart Containers
```bash
docker-compose up --build
```

## Troubleshooting
- Ensure all environment variables are correctly set
- Check Docker logs for any initialization errors
- Verify network connectivity between containers

## Security Notes
- Never commit the `.env` file to version control
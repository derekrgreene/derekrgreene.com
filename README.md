<h1 align="center">Hi 👋, I'm Derek R. Greene</h1>
<p align="center"><a href="https://www.buymeacoffee.com/derekgreene"> <img align="center" src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" height="50" width="210" alt="derekgreene" /></a></p><br><br>


# Deploy with Docker


### Pull Docker Image
```bash
docker pull derekgreene11/derekrgreene.com
```

### Create Environment File
Create a `.env` file in the project root directory with the following variables:
```
DOCKER_ENV=1
GITHUB_SECRET=<your_github_webhook_secret>
SUDO_PASSWORD=<your_sudo_password>
DBHOST=db
DBUSER=<database_username>
DBPW=<database_password>
DB=cs340
DB_HOST=db2
DB_NAME=domain_data
OUTPUT_DIR=/tmp/
```

### Copy .env to flask_proj
```bash
cp .env flask_proj/.env
```

### Run the container
```bash
docker run derekgreene11/derekrgreene.com:latest
```

### Database User Setup

#### Find MySQL Container Name
```bash
sudo docker ps
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


## Troubleshooting
- Ensure all environment variables are correctly set
- Check Docker logs for any initialization errors
- Verify network connectivity between containers

## Security Notes
- Never commit the `.env` file to version control
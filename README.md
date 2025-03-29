<h1 align="center">Hi 👋, I'm Derek R. Greene</h1>
<p align="center"><a href="https://www.buymeacoffee.com/derekgreene"> <img align="center" src="https://cdn.buymeacoffee.com/buttons/v2/default-green.png" height="50" width="210" alt="derekgreene" /></a></p>



## 🚀 Deploy with Docker

## Clone the Repository
 ```bash
 git clone https://github.com/derekgreene11/derekrgreene.com.git
 cd derekrgreene.com
 ```

## ✨ Environment Variables
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

## Copy .env to flask_proj
```bash
cp .env flask_proj/.env
```

## ⚙️ Build and Initialize Docker Containers
 ```bash
 docker-compose up --build
 ```

## Database User Setup
Find MySQL Container Name
```bash
sudo docker ps
```
Look for the container with MySQL image.

### Create Database User
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

## 📚 Troubleshooting
- Ensure all environment variables are correctly set
- Check Docker logs for any initialization errors
- Verify network connectivity between containers

## ⚠️ Security Notes
- Never commit the `.env` file to version control

<h5 align="center">Developed with &#128154; by <a href="https://derekrgreene.com">Derek R. Greene</a></h5>
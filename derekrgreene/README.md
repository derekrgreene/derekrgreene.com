![Website](https://img.shields.io/website?url=https%3A%2F%2Fderekrgreene.com&style=flat-square&logo=Elixir&label=Website%20Status&cacheSeconds=300)
![Static Badge](https://img.shields.io/badge/Elixir-1.18-blue?style=flat-square&labelColor=yellow&color=grey)
![Static Badge](https://img.shields.io/badge/Phoenix-1.7.21-red?style=flat-square&labelColor=red&color=grey)
![Static Badge](https://img.shields.io/badge/Docker-2.34.0-blue?style=flat-square&labelColor=%232496ED&color=grey)

<h1 align="center">Hi 👋, I'm Derek R. Greene</h1>
<p align="center"><a href="https://www.buymeacoffee.com/derekgreene"> <img align="center" src="https://cdn.buymeacoffee.com/buttons/v2/arial-green.png" height="50" width="210" alt="derekgreene" /></a></p>

## My Personal Website Built with Elixir & Phoenix

This is my personal website built with [Elixir](https://elixir-lang.org/) and [Phoenix Framework](https://www.phoenixframework.org/). The site features modern web technologies including Phoenix LiveView, Tailwind CSS, and system monitoring with LiveDashboard.

## 🛠️ Tech Stack

- **Backend**: Elixir with Phoenix Framework
- **Frontend**: Phoenix LiveView with Tailwind CSS
- **Containerization**: Docker & Docker Compose
- **Monitoring**: Phoenix LiveDashboard with OS metrics

## 🐳 Deploy with Docker

### Clone the Repository
```bash
git clone https://github.com/derekgreene11/derekrgreene.com.git
cd derekrgreene.com/derekrgreene
```

### ✨ Environment Variables
Create a `.env` file in the project root directory with the following variables:
```ini
DOCKER_ENV=1
ADMIN_USERNAME=<your_admin_username>
ADMIN_PASSWORD=<your_admin_password>
SECRET_KEY_BASE=<your_phoenix_secret_key>
# Flask project variables
DBPW=<database_password>
DBUSER=<database_username>
DB=<database_name>
```

**Note**: The `SECRET_KEY_BASE` is required for Phoenix security. You can generate one using `mix phx.gen.secret` if you don't have one.

### ⚙️ Build and Initialize Docker Containers
```bash
docker-compose up --build
```

## 🚀 Development (Local)

To run the application locally without Docker:

1. Install dependencies:
   ```bash
   cd derekrgreene
   mix deps.get
   ```

2. Setup assets:
   ```bash
   mix setup
   ```

3. Start the development server:
   ```bash
   mix phx.server
   ```

4. Visit [`localhost:8050`](http://localhost:8050) in your browser

## 📊 Features

- Personal portfolio and information
- LiveDashboard for system monitoring
- Responsive design with Tailwind CSS
- Docker containerization for easy deployment

<h5 align="center">Developed with &#128154; by <a href="https://derekrgreene.com">Derek R. Greene</a></h5>


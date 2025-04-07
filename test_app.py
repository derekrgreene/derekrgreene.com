import pytest
from flask import Flask
from app import app


@pytest.fixture
def client():
    with app.test_client() as client:
        yield client


def test_index(client):
    """Test the index page (home route)"""
    response = client.get('/')
    assert response.status_code == 200
    

def test_DCV_dependencies(client):
    """Test the /DCV-Dependencies route"""
    response = client.get('/DCV-Dependencies')
    assert response.status_code == 200
    

def test_domain_scout(client):
    """Test the /domain-scout route"""
    response = client.get('/domain-scout')
    assert response.status_code == 200
    

def test_garden_planter(client):
    """Test the /gardenPlanter route"""
    response = client.get('/gardenPlanter')
    assert response.status_code == 200
    

def test_inventory_tracker(client):
    """Test the /inventoryTracker route"""
    response = client.get('/inventoryTracker')
    assert response.status_code == 200
    

def test_low_level_io(client):
    """Test the /lowLevelIO route"""
    response = client.get('/lowLevelIO')
    assert response.status_code == 200
    

def test_otp(client):
    """Test the /OTP route"""
    response = client.get('/OTP')
    assert response.status_code == 200
    

def test_random_num_gen(client):
    """Test the /randomNumGen route"""
    response = client.get('/randomNumGen')
    assert response.status_code == 200
    

def test_small_sh(client):
    """Test the /smallSH route"""
    response = client.get('/smallSH')
    assert response.status_code == 200
    

def test_snake_game(client):
    """Test the /snakeGame route"""
    response = client.get('/snakeGame')
    assert response.status_code == 200
    

def test_virtual_pantry(client):
    """Test the /virtualPantry route"""
    response = client.get('/virtualPantry')
    assert response.status_code == 200
    


def test_github_pgp(client):
    """Test the /pgp route"""
    response = client.get('/pgp')
    assert response.status_code == 200
    assert b"-----BEGIN PGP PUBLIC KEY BLOCK-----" in response.data  # Adjust based on key content


def test_robots(client):
    """Test the /robots.txt route"""
    response = client.get('/robots.txt')
    assert response.status_code == 200
    assert b"User-agent: *" in response.data


def test_sitemap(client):
    """Test the /sitemap.xml route"""
    response = client.get('/sitemap.xml')
    assert response.status_code == 200
    assert b"<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">" in response.data

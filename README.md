# Synsmodell - Docker-container

## Hurtigstart
```bash
docker compose up -d --build
docker compose logs -f
```

Åpne: http://localhost:8080

Stopp Docker Compose:
```bash
docker compose down
```

Start igjen:
```bash
docker compose up -d
```

Opprydding (stopp og fjern alt fra Docker Compose):
```bash
docker compose down --rmi local --volumes --remove-orphans
```

## Beskrivelse
En interaktiv kalkulator for å simulere syn etter refraktiv kirurgi (LASIK, PRK, SMILE).

## Alternativ uten Docker Compose
### Bygg Docker-image
```bash
docker build -t synstest .
```

### Kjør containeren
```bash
docker run -d -p 8080:80 --name synstest-app synstest
```

### Stopp containeren
```bash
docker stop synstest-app
docker rm synstest-app
```

## Docker-image detaljer
- Base-image: `nginx:alpine` (~23MB)
- Eksponert port: 80
- Inneholder kun statisk HTML med JavaScript

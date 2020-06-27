# MySQLと連携するJulia API ServerのExample

## Run

```bash
docker-compose up -d
```

## Curl

### POST
```bash
curl -X POST -d '{"name":"aaa", "number":10}' localhost:8080/testapi
```

### GET
```bash
curl localhost:8080/testapi/aaa
```

### DELETE
```bash
curl -X DELETE localhost:8080/testapi/aaa
```
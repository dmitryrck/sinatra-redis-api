[![Maintainability](https://api.codeclimate.com/v1/badges/03036e914510d4015a2f/maintainability)](https://codeclimate.com/github/dmitryrck/sinatra-redis-api/maintainability)<Paste>
[![Test Coverage](https://api.codeclimate.com/v1/badges/03036e914510d4015a2f/test_coverage)](https://codeclimate.com/github/dmitryrck/sinatra-redis-api/test_coverage)

# sinatra-redis-api

This is an example REST API using sinatra and redis.

## Requests

### Get todos from a list

```terminal
$ curl \
  -H "Content-Type: application/json" \
  --data '{ "description": "test#1" }' \
  http://localhost:3000/lists/1234/todos
```

### Create a todo item

```terminal
$ curl \
  -X POST \
  -H "Content-Type: application/json" \
  --data '{ "uuid": 1234, "description": "test#1" }' \
  http://localhost:3000/lists/1234/todos
```

### Update a todo item

```terminal
$ curl \
  -X PUT \
  -H "Content-Type: application/json" \
  --data '{ "description": "test#2" }' \
  http://localhost:3000/lists/1234/todos/1234
```

### Delete a todo item from a list

```
$ curl \
  -X DELETE \
  -H "Content-Type: application/json" \
  http://localhost:3000/lists/1234/todos/1234
```

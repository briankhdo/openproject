# Projects

## Create a project

API for creating a new project which has reporting and costs modules enabled

### Request method: `POST`

### Endpoint: '/appop/api/v1/projects'

### Request body

Param           | Data Type   | Required  | Description
--------------- | ----------- | --------- | -----------
`name`          | string      | TRUE      | Project name
`description`   | string      | TRUE      | Project description
`is_public`     | boolean     | FALSE     | Set project public or private
`parent_id`     | integer     | FALSE     | If project has parent
`identifier`    | string      | TRUE      | Project slug will be on url

### Response

A project object
```javascript
{
  "id": 6,
  "name": "Dev-custom-fields",
  "description": null,
  "identifier": "dev-custom-fields",
  "status": 1,
  "created_on": "03/11/2019 09:29 AM",
  "updated_on": "04/02/2019 07:06 AM"
}
```

## Update a project

API for updating an existing project

### Request method: `PUT`

### Endpoint: '/appop/api/v1/projects/:project_id'

### Request body

Param           | Data Type   | Required  | Description
--------------- | ----------- | --------- | -----------
`name`          | string      | TRUE      | Project name
`description`   | string      | TRUE      | Project description
`is_public`     | boolean     | FALSE     | Set project public or private
`parent_id`     | integer     | FALSE     | If project has parent
`identifier`    | string      | TRUE      | Project slug will be on url
`status`        | integer     | FALSE     | Update project status

### Response

A project object
```javascript
{
  "id": 6,
  "name": "Dev-custom-fields",
  "description": null,
  "identifier": "dev-custom-fields",
  "status": 1,
  "created_on": "03/11/2019 09:29 AM",
  "updated_on": "04/02/2019 07:06 AM"
}
```

## Archive a project

API for archiving an existing project

### Request method: `POST`

### Endpoint: '/appop/api/v1/projects/:project_id/archive'

### Response

An archived project object
```javascript
{
  "id": 6,
  "name": "Dev-custom-fields",
  "description": null,
  "identifier": "dev-custom-fields",
  "status": 9,
  "created_on": "03/11/2019 09:29 AM",
  "updated_on": "04/02/2019 07:06 AM"
}
```

# Members

## List members

API for listing all project members

### Request method: `GET`

### Endpoint: '/appop/api/v1/projects/:project_id/members'

### Response

An array `response["items"]` of user objects represent project's current members
```javascript
{
  "id": 3,
  "firstname": "Reader",
  "lastname": "DEV user",
  "mail": "reader@example.net",
  "avatar": "http://gravatar.com/avatar/9adda4ca04d9043eb55a999dd307eae0?default=404&secure=false",
  "roles": [
    {
      "id": 5,
      "name": "Reader"
    }
  ]
}
```

Example
```javascript
{
  "_type": "Array",
  "items": [
    {
      "id": 3,
      "firstname": "Reader",
      "lastname": "DEV user",
      "mail": "reader@example.net",
      "avatar": "http://gravatar.com/avatar/9adda4ca04d9043eb55a999dd307eae0?default=404&secure=false",
      "roles": [
        {
          "id": 5,
          "name": "Reader"
        }
      ]
    },
    {
      "id": 4,
      "firstname": "Member",
      "lastname": "DEV user",
      "mail": "member@example.net",
      "avatar": "http://gravatar.com/avatar/17dd23570f3bd129d06db9b48b7a41b8?default=404&secure=false",
      "roles": [
        {
          "id": 4,
          "name": "Member"
        }
      ]
    },
    {
      "id": 5,
      "firstname": "Project admin",
      "lastname": "DEV user",
      "mail": "project_admin@example.net",
      "avatar": "http://gravatar.com/avatar/56b9f6fbffd08e01e3569fe213ec00a7?default=404&secure=false",
      "roles": [
        {
          "id": 3,
          "name": "Project admin"
        }
      ]
    }
  ]
}
````

## Add members to a project

API for adding a list of members with roles

### Request method: `POST`

### Endpoint: '/appop/api/v1/projects/:project_id/members'

### Request body

An array of hash having user_id and role_id
```javascript
{
  "members": [
    {
      "user_id": 1,
      "role_id": 1
    },
    {
      "user_id": 2,
      "role_id": 1
    }
  ]
}
```

Please note getting roles using this endpoint
`GET /api/v3/roles`

### Response

An array `response["items"]` of user objects represent project's current members

## Remove members from a project

API to remove a member from a project

### Request method: `DELETE`

### Endpoint: '/appop/api/v1/projects/:project_id/members/:user_id'

### Response

An array `response["items"]` of user objects represent project's current members

# Costs Log

## Log costs

API for logging costs for a work package.
Please note that costs log is from the authorized user (current user)

### Request method: `POST`

### Endpoint: '/work_packages/:work_package_id/costlog'

### Request body

Param             | Data Type   | Required  | Description
----------------- | ----------- | --------- | -----------
`work_package_id` | integer     | TRUE      | Work package id to log
`cost_type_id`    | integer     | FALSE     | Cost type (please check administration to create one). Default cost type will be selected if not specified
`units`           | float       | TRUE      | Units of work (depent on administration setup)
`spent_on`        | date        | FALSE     | Date of costs log. Default today
`comments`        | string      | TRUE      | Add comments. Default empty


### Response

An information object that tells the log is success
```javascript
{
  "_type":"Info",
  "message":"Log completed"
}
```

# Workspace idenfitication

Please use `X-Workspace-Name` to input project identifier as a workspace.
Workspace will affect all the API bellow

Sample CURL request
```
curl -XPOST http://localhost:3000/appop/api/v1/users
  -H "Content-Type: application/json"
  -H 'Authorization: Basic YXBpa2V5Ojk0NGE2OTQ0ZjgxMzNiZDVmYWJjOGRiYmVkMTQ4Zjc2NjA2NzY4NTNmMmU5YjA0YzJiNzQ3NzQ4MGE0MTI2M2U='
  -H 'X-Workspace-Name: your-scrum-project'
  -d '{
  "firstname": "Bang",
  "lastname": "Nguyen",
  "login": "bangnl",
  "mail": "bangnl@appota.com",
  "role_id": 4
}'
```

# Projects

## List workspace's projects

API for listing workspace's projects

### Request method: `GET`

### Endpoint: '/appop/api/v1/projects'
Listing active projects
`GET` `/appop/api/v1/projects/active`
Listing archived projects
`GET` `/appop/api/v1/projects/archived`

### Response

An array of project objects

```javascript
{
  "_type": "Collection",
  "_workspace": "your-scrum-project",
  "items": [
    // array of projects
  ]
}
```

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
`parent_id`     | integer     | FALSE     | If project has parent. Default parent will be workspace
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
`parent_id`     | integer     | FALSE     | Updating parent_id is prohibited for direct-children of a workspace
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

## Unarchive a project

API for unarchiving an archived project

### Request method: `POST`

### Endpoint: '/appop/api/v1/projects/:project_id/unarchive'

### Response

An active project object
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

## Project roadmap

API for getting project roadmap (versions)

### Request method: `GET`

### Endpoint: '/appop/api/v1/projects/:project_id/roadmap'

### Response

An array of versions and related issues, wiki content
```javascript
{
  "_type": "Collection",
  "items": [
    {
      "id": 3,
      "project_id": 1,
      "name": "Sprint 1",
      "description": "",
      "effective_date": null,
      "created_on": "03/11/2019/ 09:29 AM",
      "updated_on": "03/11/2019/ 09:29 AM",
      "wiki_page_title": "Sprint 1",
      "status": "open",
      "sharing": "none",
      "start_date": "2019-04-01",
      "issues": [
        {
          "id": 7,
          "type_id": 1,
          "project_id": 1,
          "subject": "Create wireframes for new landing page",
          "description": null,
          "due_date": "2019-04-06",
          "category_id": null,
          "status_id": 7,
          "assigned_to_id": 1,
          "priority_id": 8,
          "fixed_version_id": 3,
          "author_id": 1,
          "lock_version": 1,
          "done_ratio": 0,
          "estimated_hours": null,
          "created_at": "03/11/2019/ 09:29 AM",
          "updated_at": "03/11/2019/ 09:29 AM",
          "start_date": "2019-04-06",
          "responsible_id": null,
          "cost_object_id": null,
          "position": 1,
          "story_points": null,
          "remaining_hours": null,
          "parent_id": 6
        }
      ],
      "wiki_content": {
        "id": 1,
        "page_id": 1,
        "author_id": 1,
        "text": "### Sprint planning meeting\n\n_Please document here topics to the Sprint planning meeting_\n\n* Time boxed (8 h)\n* Input: Product Backlog\n* Output: Sprint Backlog\n\n* Divided into two additional time boxes of 4 h:\n\n    * The Product Owner presents the team the [Product Backlog](/projects/your-scrum-project/backlogs) and the priorities and explanes the Sprint Goal, to which the team must agree. Together, they prioritize the topics from the Product Backlog which the team will take care of in the next sprint. The team committs to the discussed delivery.\n    * The team plans autonomously (without the Product Owner) in detail and breaks down the tasks from the discussed requirements to consolidate a [Sprint Backlog](/projects/your-scrum-project/backlogs).\n\n\n### Daily Scrum meeting\n\n_Please document here topics to the Daily Scrum meeting_\n\n* Short, daily status meeting of the team.\n* Time boxed (max. 15 min).\n* Stand-up meeting to discuss the following topics from the [Task board](/projects/your-scrum-project/sprints/3/taskboard).\n    * What do I plan to do until the next Daily Scrum?\n    * What has blocked my work (Impediments)?\n* Scrum Master moderates and notes down [Sprint Impediments](/projects/your-scrum-project/sprints/3/taskboard).\n* Product Owner may participate may participate in order to stay informed.\n\n### Sprint Review meeting\n\n_Please document here topcis to the Sprint Review meeting_\n\n* Time boxed (4 h).\n* A maximum of one hour of preparation time per person.\n* The team shows the product owner and other interested persons what has been achieved in this sprint.\n* Important: no dummies and no PowerPoint! Just finished product functionality (Increments) should be demonstrated.\n* Feedback from Product Owner, stakeholders and others is desired and will be included in further work.\n* Based on the demonstrated functionalities, the Product Owner decides to go live with this increment or to develop it further. This possibility allows an early ROI.\n\n\n### Sprint Retrospective\n\n_Please document here topcis to the Sprint Retrospective meeting_\n\n* Time boxed (3 h).\n* After Sprint Review, will be moderated by Scrum Master.\n* The team discusses the sprint: what went well, what needs to be improved to be more productive for the next sprint or even have more fun.\n",
        "updated_on": "03/11/2019/ 09:29 AM",
        "lock_version": 0
      }
    },
    {
      "id": 4,
      "project_id": 1,
      "name": "Sprint 2",
      "description": "",
      "effective_date": null,
      "created_on": "03/11/2019/ 09:29 AM",
      "updated_on": "03/11/2019/ 09:29 AM",
      "wiki_page_title": null,
      "status": "open",
      "sharing": "none",
      "start_date": null,
      "issues": []
    }
  ]
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

# Users
## Create a user

API for creating a new user in the workspace defined in header

### Request method: `POST`

### Endpoint: '/appop/api/v1/users'

### Request body

Param           | Data Type   | Required  | Description
--------------- | ----------- | --------- | -----------
`mail`          | string      | TRUE      | User's email
`login`         | string      | TRUE      | Username to login
`firstname`     | string      | TRUE      | User's first name
`lastname`      | string      | TRUE      | User's last name
`password`      | string      | FALSE     | Password
`role_id`       | integer     | FALSE     | Default role_id: 4 (member)

### Response

A user object
```javascript
{
  "_type": "User",
  "_workspace": "your-scrum-project",
  "id": 8,
  "firstname": "Bang",
  "lastname": "Nguyen",
  "login": "bangnl",
  "mail": "bangnl@appota.com",
  "status": 1,
  "created_on": "05/07/2019/ 04:41 AM",
  "updated_on": "05/08/2019/ 03:41 AM",
  "name": "Bang Nguyen",
  "api_token": "1f882277097d3727f9950b599529268dd8fbf0712fa5b0e157de76704c8d9a3e"
}
```
## Update user

API for updating a user. Only admin can modify any users, normal user (member) will only be able to update her/himself, using id=current

### Request method: `PUT`

### Endpoint: '/appop/api/v1/users/:id'

### Request body

Param           | Data Type   | Required  | Description
--------------- | ----------- | --------- | -----------
`mail`          | string      | TRUE      | User's email
`login`         | string      | TRUE      | Username to login
`firstname`     | string      | TRUE      | User's first name
`lastname`      | string      | TRUE      | User's last name
`password`      | string      | FALSE     | Password

### Response

A user object
```javascript
{
  "_type": "User",
  "_workspace": "your-scrum-project",
  "id": 8,
  "firstname": "Bang",
  "lastname": "Nguyen",
  "login": "bangnl",
  "mail": "bangnl@appota.com",
  "status": 1,
  "created_on": "05/07/2019/ 04:41 AM",
  "updated_on": "05/08/2019/ 03:41 AM",
  "name": "Bang Nguyen",
  "api_token": "1f882277097d3727f9950b599529268dd8fbf0712fa5b0e157de76704c8d9a3e"
}
```

## Remove user from workspace

API for removing a user from workspace. Only admin!

### Request method: `DELETE`

### Endpoint: '/appop/api/v1/users/:id'

### Response

A user object
```javascript
{
  "success": true
}
```

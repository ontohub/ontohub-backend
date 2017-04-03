# Repositories

## Actions
### Create
###### Route
    POST /repositories
###### Example Commands
    $ http POST :3000/repositories data:='{"attributes":{"name": "some repository", "content_type": "ontology", "public_access": "true", "description": "some description" }, "relationships": {"owner": {"data": {"type": "users", "id": "ada"}}}}'
    $ http POST :3000/repositories data:='{"attributes":{"name": "some repository", "content_type": "ontology", "public_access": "true", "description": "some description" }, "relationships": {"owner": {"data": {"type": "organizations", "id": "all-users"}}}}'
###### Description
Creates a repository.

#### Request Data
##### Required
* `name` [String]: The name of the repository to be created.
* `content_type` [String]: The content type of the repository. Must be one of `"ontology"`, `"model"`, `"specification"`, `"mathematical"`.
* `public_access` [Boolean]: Describes whether or not this repository is publicly accessible. Must be one of `true`, `false`.

###### Required Relationships
* `owner` [[User Relationship Object](users.md#relationship-object) / [Organization Relationship Object](organizations.md#relationship-object)]: The repository owner.

##### Optional
* `description` [String]: A short descriptive text.

#### Response Data
* 201/Created: Contains the new [Resource Object](#resource-object).
* 422/Unprocessable Entity: Contains a [Validation Error Object](README.md#validation-error-object).

---

### Index
###### Route
    GET /users/:user_id/repositories
    GET /organizations/:organization_id/repositories
###### Example Command
    $ http -j :3000/users/ada/repositories
###### Description
Lists all repositories of the given owner.

#### Response Data
* 200/OK: Contains an array of [Resource Objects](#resource-object).

---

### Read
###### Route
    GET /repositories/:repository_id
**Note that a `repository_id` includes the ID of the owner.**
###### Example Command
    $ http -j :3000/repositories/ada/repo1
###### Description
Lists all information on the repository with the ID `ada/repo1`.

#### Response Data
* 200/OK: Contains the [Resource Object](#resource-object).

---

### Update
###### Route
    PATCH /repositories/:repository_id
**Note that a `repository_id` includes the ID of the owner.**
###### Example Command
    $ http PATCH :3000/repositories/ada/repo1 data:='{"attributes":{"description": "a new description"}}'
###### Description
Changes attributes of the repository `ada/repo1`.

#### Request Data
##### Optional
* `description` [String]: A short descriptive text.
* `content_type` [String]: The content type of the repository. Must be one of `"ontology"`, `"model"`, `"specification"`, `"mathematical"`.
* `public_access` [Boolean]: Describes whether or not this repository is publicly accessible. Must be one of `true`, `false`.

#### Response Data
* 200/OK: Contains the updated [Resource Object](#resource-object).
* 422/Unprocessable Entity: Contains a [Validation Error Object](README.md#validation-error-object).

---

### Delete
###### Route
    DELETE /repositories/:repository_id
**Note that a `repository_id` includes the ID of the owner.**
###### Example Command
    $ http DELETE :3000/repositories/ada/repo1
###### Description
Deletes the repository `ada/repo1`.

#### Response Data
* 204/No Content: Successfully deleted (No response body)

-

## Response Objects
### Resource Object
###### Fields
* `id` [String]: The ID of the repository (including the ID of the owner).
* `type` [String]: *Always* `"repositories"`.
* `attributes` [Object]: See [Attributes](#attributes).
* `relationships` [Object]: See [Relationships](#relationships).
* `links` [Object]: See [Links](#links).

###### Attributes
* `name` [String]: The name of the repository to be created.
* `content_type` [String]: The content type of the repository. Must be one of `"ontology"`, `"model"`, `"specification"`, `"mathematical"`.
* `public_access` [Boolean]: Describes whether or not this repository is publicly accessible. Must be one of `true`, `false`.
* `description` [String]: A short descriptive text.

###### Relationships
* `owner` [[User Relationship Object](users.md#relationship-object) / [Organization Relationship Object](organizations.md#relationship-object)]: The repository owner.
  * The link to this relationship is in the `related` key.

###### Links
* `self` [URL]: The URL of the resource itself.

### Relationship Object
###### Fields
* `id` [String]: The name of the repository.
* `type` [String]: *Always* `"repositories"`.

###### Links
* `related` [URL]: The URL of the repository itself.

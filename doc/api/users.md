# Users

## Actions
### Read
###### Route
    GET /users/:user_id
###### Example Command
    $ http -j :3000/users/ada
###### Description
Lists all information on the user with the ID `ada`.

#### Response Data
* 200/OK: Contains the [Resource Object](#resource-object).

-

## Response Objects
### Resource Object
###### Fields
* `id` [String]: The ID of the user.
* `type` [String]: *Always* `"users"`.
* `attributes` [Object]: See [Attributes](#attributes).
* `relationships` [Object]: See [Relationships](#relationships).
* `links` [Object]: See [Links](#links).

###### Attributes
* `name` [String]: The name of the user.
* `email`: [String]: The email address of the user.

###### Relationships
* `organizations` - [Array of [Organization Relationship Objects](organizations.md#relationship-object)]: The index of the organizations this user belongs to.

###### Links
* `self` [URL]: The URL of the user itself.

### Relationship Object
###### Fields
* `id` [String]: The ID of the user.
* `type` [String]: *Always* `"users"`.

###### Links
* `self` [URL]: The URL of the user itself.

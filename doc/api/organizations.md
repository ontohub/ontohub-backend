# Organizations

## Actions
### Read
###### Route
    GET /organizations/:organization_id
###### Example Command
    $ http -j :3000/organizations/all-users
###### Description
Lists all information on the organization with the ID `all-users`.

#### Response Data
* 200/OK: Contains the [Resource Object](#resource-object).

-

## Response Objects
### Resource Object
###### Fields
* `id` [String]: The ID of the organization.
* `type` [String]: *Always* `"organizations"`.
* `attributes` [Object]: See [Attributes](#attributes).
* `relationships` [Object]: See [Relationships](#relationships).
* `links` [Object]: See [Links](#links).

###### Attributes
* `name` [String]: The name of the organization.

###### Relationships
* `members` - [Array of [User Relationship Objects](users.md#relationship-object)]: The index of the organizations this organization belongs to.

###### Links
* `self` [URL]: The URL of the organizations itself.

### Relationship Object
###### Fields
* `id` [String]: The ID of the organization.
* `type` [String]: *Always* `"organizations"`.

###### Links
* `related` [URL]: The URL of the organization itself.

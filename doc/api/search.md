# Search

## Actions
### Search
###### Route
    GET /search
###### Example Command
    $ http -j :3000/search
###### Description
Lists all resources that match the search query.

#### Request Data
Currently not used at all.
The data format will be published later in this place.

#### Response Data
* 200/OK: Contains the [Resource Object](#resource-object).

-

## Response Objects
### Resource Object
###### Fields
* `id` [String]: *Always* `"searchresult"`.
* `type` [String]: *Always* `"searchresult"`.
* `attributes` [Object]: See [Attributes](#attributes).
* `relationships` [Object]: See [Relationships](#relationships).
* `links` [Object]: See [Links](#links).

###### Attributes
* `repositories_count` [Integer]: The number of matching repositories.
* `users_count` [Integer]: The number of matching users.
* `organizations_count` [Integer]: The number of matching organizations.
* `results_count` [Integer]: The total number of matching resources (sum of the other `*_count` fields).

###### Relationships
* `repositories` - [Array of [Repository Relationship Objects](repositories.md#relationship-object) without `"links"`]: The index of the matching repositories.
* `users` - [Array of [User Relationship Objects](users.md#relationship-object) without `"links"`]: The index of the matching users.
* `organizations` - [Array of [Organization Relationship Objects](organizations.md#relationship-object) without `"links"`]: The index of the matching organizations.

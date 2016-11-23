# Namespaces

## Actions
### Read
###### Route
    GET /namespaces/:namespace_id
###### Example Command
    $ http -j :3000/namespaces/ada
###### Description
Lists all information on the namespace with the ID `ada`.

#### Response Data
* 200/OK: Contains the [Resource Object](#resource-object).

-

## Response Objects
### Resource Object
###### Fields
* `id` [String]: The name of the namespace.
* `type` [String]: *Always* `"namespaces"`.
* `attributes` [Object]: See [Attributes](#attributes).
* `relationships` [Object]: See [Relationships](#relationships).
* `links` [Object]: See [Links](#links).

###### Attributes
* `name` [String]: The name of the namespace.

###### Relationships
* `repositories` - [[Repository Relationship Object](repositories.md#relationship-object)]: The index of the repositories in this namespace.

###### Links
* `self` [URL]: The URL of the namespace itself.

### Relationship Object
###### Fields
* `id` [String]: The name of the namespace.
* `type` [String]: *Always* `"namespaces"`.

###### Links
* `self` [URL]: The URL of the namespace itself.

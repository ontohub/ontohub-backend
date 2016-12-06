# API Documentation
This directory contains the API documentation.
It describes which URL must be called to create, read, update and destroy a resource, which arguments must be included and to query for information.

# Tool Recommendations

We recommend to use [httpie](https://httpie.org) to interact with the API for development.
This tool simplifies header specification and data transmission to the server.

# Conventions

The API strictly follows the [JSON API](http://jsonapi.org) version [1.0](http://jsonapi.org/format/1.0).
This API documentation omits the following information:
* The `data` key is always present in a successful API call that returns a JSON body.
  This documentation does not include it, although it is present in the output.
* On each `POST` request, the attributes must be wrapped in a JSON object like this:

    ```
    {
      "data: {
        "type": "some_resource_type",
        "attributes": {
          ...
        }
      }
    }
    ```
    However, we will only define the keys of the inner `attributes` object.
    Everything outside of the `attributes` object is given implicitly.
    In particular, the value of the `type` string is *always* the name of the resource model in pluralized, lower snake case form.
* On a request that returns a resource, an `id` and a `type` field are always included in the response.
  These are omitted in the detailed API documentation.
  The value of the `type` string is *always* the name of the resource model in pluralized, lower snake case form.
  The value of the `id` field is sometimes an integer and sometimes a string.

# General Responses
## Objects
### Validation Error Object
The validation error object contains an `errors` array that lists validation errors and points to the source of the error in the object of the request body.
An example is
```
{
    "errors": [
        {
            "detail": "is not present",
            "source": {
                "pointer": "/data/attributes/owner_id"
            }
        },
        {
            "detail": "is invalid",
            "source": {
                "pointer": "/data/attributes/name"
            }
        }
    ]
}
```

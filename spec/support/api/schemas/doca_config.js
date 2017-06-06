// this is passed to json-schema-example-loader
export default {
  title: 'Ontohub API Documentation',
  curl: {
    baseUrl: 'http://localhost:3000',
    requestHeaders: {
      required: [
        // 'Authorization',
        'Content-Type'
      ],
      properties: {
        'Content-Type': {
          type: 'string',
          enum: [
            'application/json',
          ],
          example: 'application/json',
          description: 'Content type of the API request',
        },
        'Authorization': {
          type: 'string',
          example: 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiJ9.eyJ1c2VyX2lkIjoiYWRhIiwiZXhwIjoxNDk2MTUzOTE4fQ.oENJruTivv7q7PdP1W1tTuZIfpjK-wuzLuSei-tbUMW_CAZ0xwYvfIRFJiHEcFq1AtLM_zYdpq-TVfmlSSNlqQ',
          description: 'Authorization header that contains the token from the sign-in endpoint'
        }
      }
    }
  }
};

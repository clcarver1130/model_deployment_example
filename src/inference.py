import pickle
import os
import json
import logging
import numpy as np
from sklearn.base import is_classifier

# Configure logging
logging.basicConfig(level=logging.INFO)

# Define the model path
MODEL_PATH = os.path.join(os.path.dirname(__file__), 'model.pkl')

# Load the model once globally for cold start optimization
MODEL = None
try:
    with open(MODEL_PATH, 'rb') as f:
        MODEL = pickle.load(f)
    logging.info("Model loaded successfully.")
except Exception as e:
    logging.error(f"Error loading model: {e}")


def handler(event, context):
    """
    The main handler function for the AWS Lambda.
    """
    if MODEL is None:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Model failed to load.'})
        }

    try:
        # The event body comes as a string from API Gateway
        # Note: API Gateway HTTP API (v2.0 payload) sends the body as a string
        body = json.loads(event['body'])

        # Expect the input in a simple format, e.g., {"features": [1, 2, 3, 4]}
        features = body.get('features')

        if not features or not isinstance(features, list):
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'Invalid input format. Expected {"features": [f1, f2, ...]}'})
            }

        logging.info(f"Received features: {features}")

        input_array = np.array(features).reshape(1, -1)

        # Perform prediction
        prediction_result = MODEL.predict(input_array).tolist()  # Convert numpy array output to list
        response = {
            'prediction': prediction_result[0] if prediction_result else None
        }
        logging.info(f"Prediction made: {prediction_result}")

        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps(response)
        }

    except json.JSONDecodeError:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Invalid JSON body.'})
        }
    except Exception as e:
        logging.error(f"Prediction error: {e}", exc_info=True)
        return {
            'statusCode': 500,
            'body': json.dumps({'error': f'Internal server error: {str(e)}'})
        }


# For local testing (optional, not part of Lambda deployment)
if __name__ == '__main__':

    dummy_event = {
        'body': json.dumps({
            "features": [5.1, 3.5, 1.4, 0.2]  # Example input for the Iris model
        })
    }

    response = handler(dummy_event, None)
    print(response)
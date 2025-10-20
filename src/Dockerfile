# Use the official AWS Lambda Python base image
FROM public.ecr.aws/lambda/python:3.12

# Copy inference code and model to the working directory
# We put them in the 'inference' directory locally
COPY inference.py ${LAMBDA_TASK_ROOT}
COPY model.pkl ${LAMBDA_TASK_ROOT}
COPY requirements.txt ${LAMBDA_TASK_ROOT}

# Install necessary Python packages (e.g., scikit-learn for model inference)
RUN pip install -r requirements.txt

# Set the CMD to your handler (e.g., 'inference.handler')
# 'inference' is the file name, 'handler' is the function name
CMD [ "inference.handler" ]
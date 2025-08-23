# Use an official lightweight Python image
FROM python:3.12-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt .

# Install the Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of your application code into the container
COPY . .

# Expose the port the app will run on
EXPOSE 5001

# The command to run your application using Gunicorn
# This is the production-ready way to run a Flask app
CMD ["gunicorn", "--bind", "0.0.0.0:5001", "app:app"]
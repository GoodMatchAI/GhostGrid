# Use an official lightweight Python image
FROM python:3.12-slim

# Tell Python to run in unbuffered mode, which is better for container logging
ENV PYTHONUNBUFFERED=1

# Set the working directory inside the container
WORKDIR /app

# Install system build tools needed for C++ compilation (g++, make, etc.)
RUN apt-get update && apt-get install -y build-essential

# Copy the requirements file into the container
COPY requirements.txt .

# Install the Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of your application code into the container
COPY . .

# Expose the port the app will run on
EXPOSE 5001

# The command to run your application using Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:5001", "app:app"]

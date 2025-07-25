FROM python:3.10-slim-buster
WORKDIR /app

  # Copy the requirements file into the container at /app
  COPY requirements.txt .

  # Install any needed packages specified in requirements.txt
  RUN pip install --no-cache-dir -r requirements.txt

  # Copy the rest of the application code into the container at /app
  COPY . .

  # Make port 5000 available to the world outside this container
  EXPOSE 5000

  # Define environment variable
  ENV NAME=World

  # Run app.py when the container launches
  CMD ["python", "app.py"]
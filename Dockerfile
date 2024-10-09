# Use the official Python image as the base image
FROM python:3.12

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt .

# Install the required Python packages
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire application into the container
COPY . .

# Copy the domains.txt file into the container
COPY domains.txt .

# Set the entry point for the container to run the main script
ENTRYPOINT ["python", "main.py", "--file", "domains.txt"]

# Base image
FROM python:3.10-slim

# Create a non-root user
RUN useradd -m nonrootuser

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set working directory
WORKDIR /app

# Copy requirements file and install dependencies
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . /app/

# Switch to non-root user
USER nonrootuser

# Expose port
EXPOSE 8000

# Run the application
CMD ["python", "run.py"]
# Use an existing Apache image as the base
FROM devopsedu/webapp:latest

# Copy all files from the current directory to the web server's root
COPY . /var/www/html/

# Expose port 80 for web traffic
EXPOSE 80

# Start the Apache server in the foreground
CMD ["apachectl", "-D", "FOREGROUND"]

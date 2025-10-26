FROM cirrusci/flutter:3.29.0-web
WORKDIR /app
COPY . .
RUN flutter config --enable-web \
  && flutter pub get \
  && flutter build web --release
CMD ["flutter", "run", "-d", "web-server", "--web-port=8080", "--web-hostname=0.0.0.0"]

# Build stage
FROM golang:1.23-bookworm AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=1 GOOS=linux go build -o meeting-bot .

# Final stage
FROM debian:bookworm-slim

# Update the package installation command in Final stage
RUN apt-get update && apt-get install -y \
    python3-pip python3-venv ffmpeg pulseaudio \
    nodejs npm \
    libgstreamer-plugins-base1.0-0 libgstreamer1.0-0 \
    libnss3 libnspr4 libatk1.0-0 libatk-bridge2.0-0 \
    libcups2 libdrm2 libxkbcommon0 libxcomposite1 \
    libxdamage1 libxfixes3 libxrandr2 libgbm1 \
    && rm -rf /var/lib/apt/lists/*

# Install Python deps
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install torch torchaudio openai-whisper

# Install Playwright browsers
RUN mkdir -p /usr/share/playwright && \
    PLAYWRIGHT_BROWSERS_PATH=/usr/share/playwright npx playwright install chromium

# Install Ollama
RUN curl -L https://ollama.ai/download/ollama-linux-amd64 -o /usr/bin/ollama \
    && chmod +x /usr/bin/ollama

COPY --from=builder /app/meeting-bot /app/
COPY transcribe.py /app/

WORKDIR /app
CMD ["/app/meeting-bot"]
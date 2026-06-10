FROM node:22-bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
      git curl jq ffmpeg ca-certificates openssh-client fontconfig \
  && rm -rf /var/lib/apt/lists/*
RUN curl -fsSL -o /usr/local/bin/kubectl \
      "https://dl.k8s.io/release/v1.35.0/bin/linux/amd64/kubectl" \
  && chmod +x /usr/local/bin/kubectl
RUN npm install -g @anthropic-ai/claude-code

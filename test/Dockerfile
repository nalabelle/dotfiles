# Multi-stage build for testing Linux deployment with integrated verification

# Stage 1: Build - Set up environment and run Home Manager
FROM alpine:latest AS build

# Install required packages including CA certificates
RUN apk add --no-cache bash curl xz git jq sudo ca-certificates

# Create test user
RUN addgroup -g 1000 nalabelle && adduser -D -u 1000 -G nalabelle -s /bin/bash nalabelle
RUN echo "nalabelle ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Switch to test user
USER nalabelle
ENV HOME=/home/nalabelle USER=nalabelle
WORKDIR /home/nalabelle

# Install Nix (this layer will be cached)
RUN curl -L https://nixos.org/nix/install | sh
RUN echo '. ~/.nix-profile/etc/profile.d/nix.sh' >> ~/.bashrc

# Set Nix environment variables
ENV PATH="/home/nalabelle/.nix-profile/bin:${PATH}"
ENV NIX_PROFILES="/nix/var/nix/profiles/default /home/nalabelle/.nix-profile"
ENV NIX_SSL_CERT_FILE="/etc/ssl/certs/ca-certificates.crt"

# Enable flakes (this layer will be cached)
RUN mkdir -p ~/.config/nix
RUN echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf

# Copy the dotfiles project (this invalidates subsequent layers when content changes)
COPY --chown=nalabelle:nalabelle . ./dotfiles/
WORKDIR /home/nalabelle/dotfiles

# Apply home manager config (only runs when dotfiles change)
RUN rm -f ~/.config/nix/nix.conf ~/.bashrc
RUN mkdir -p ~/.config/nix && echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
RUN echo "Building Home Manager configuration..."
RUN nix run github:nix-community/home-manager -- switch --flake . -b backup

# Stage 2: Verify - Run verification during build process
FROM build AS verify

# Copy verification script into the container
COPY --chown=nalabelle:nalabelle test/verify.sh /home/nalabelle/verify.sh
RUN chmod +x /home/nalabelle/verify.sh

# Run verification as part of the build - build will fail if verification fails
RUN echo "Running deployment verification..." && \
    bash -c ". ~/.nix-profile/etc/profile.d/nix.sh && /home/nalabelle/verify.sh"

# Success message for completed build
RUN echo "✅ Multi-stage build completed successfully with verification passed!"

# Default command for manual container inspection if needed
CMD ["bash", "-c", ". ~/.nix-profile/etc/profile.d/nix.sh && echo 'Container ready for inspection. Run /home/nalabelle/verify.sh to re-run verification.' && bash"]

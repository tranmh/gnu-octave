# Build agent for the GNU Octave stages of the Jenkinsfile: Octave, MOxUnit and MOcov (pinned commits).
FROM debian:trixie-slim
RUN apt-get update && apt-get install -y --no-install-recommends octave git ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && git clone -q https://github.com/MOxUnit/MOxUnit /opt/MOxUnit && git -C /opt/MOxUnit checkout -q 51536d60d0b3aea7b8819650b101668e8fff9973 \
    && git clone -q https://github.com/MOcov/MOcov /opt/MOcov && git -C /opt/MOcov checkout -q 6cb29e52660b95964ee9f955d1fe9ec5234fa40f
ENV MOXUNIT_DIR=/opt/MOxUnit MOCOV_DIR=/opt/MOcov

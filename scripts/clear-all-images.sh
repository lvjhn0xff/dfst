#!/bin/bash
echo ":: Removing containers, volumes, and images for prefix '${PROJECT_DOCKERHUB_PREFIX}'"

# 1. Find all images that match the prefix
IMAGES=$(docker images --format '{{.Repository}}:{{.Tag}}' | grep "^${PROJECT_DOCKERHUB_PREFIX}" || true)

if [ -z "$IMAGES" ]; then
    echo "No images found with prefix '${PROJECT_DOCKERHUB_PREFIX}'."
    exit 0
fi

# 2. Find and remove containers that use those images
for IMAGE in $IMAGES; do
    CONTAINERS=$(docker ps -a --filter "ancestor=$IMAGE" --format '{{.ID}}')
    if [ -n "$CONTAINERS" ]; then
        echo ":: Stopping and removing containers for image '$IMAGE'..."
        docker rm -f $CONTAINERS || true
    fi
done

# 3. Remove all unused volumes (optional but usually desired)
echo ":: Removing dangling/unused volumes..."
docker volume prune -f || true

# 4. Remove the images themselves
echo ":: Removing matching images..."
docker rmi -f $IMAGES || true

echo ":: Cleanup complete!"

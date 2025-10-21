#!/bin/bash
sudo usermod -aG docker $USER
newgrp docker
docker ps
docker exec -it supabase-db psql -U postgres -d postgres -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
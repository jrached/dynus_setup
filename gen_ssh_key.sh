cd /home/swarm
echo -e "\n\n\n" | ssh-keygen -t ed25519 -C "juanrached@gmail.com"
ssh-add /home/swarm/.ssh/id_ed25519

cat /home/swarm/.ssh/id_ed25519.pub
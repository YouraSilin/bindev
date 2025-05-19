mkdir newapp

git clone https://github.com/YouraSilin/bindev.git newapp

cd newapp

docker compose build

docker compose run --no-deps web rails new . --force --database=postgresql --css=bootstrap

replace this files

https://github.com/YouraSilin/bindev/blob/main/config/database.yml

https://github.com/YouraSilin/bindev/blob/main/Dockerfile

https://github.com/YouraSilin/bindev/blob/main/Gemfile

docker compose up

docker compose exec web rake db:create db:migrate

sudo chown -R $USER:$USER .
